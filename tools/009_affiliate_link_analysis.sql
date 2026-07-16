-- =====================================================================
-- 009 Affiliate LINK analysis — tầng logic "phủ link chất lượng".
-- Định nghĩa đã chốt với chủ dự án:
--  • Tiền = item_total_comm (per-SP, GROSS, KHÔNG trừ MCN). Tổng = order_total_comm.
--  • Trạng thái tính tiền = Completed + Pending (Cancelled = 0).
--  • Đơn vị = item_id (LINK sản phẩm), gom xuyên account.
--  • ENRICH: rate hoa hồng THẬT ưu tiên từ crawler (products.seller_commission),
--    KHÔNG tin item_seller_comm_rate của report (chỉ là ngữ cảnh attribution).
--  • Phân loại link: PHU (có tiền) / HUNT (0 tiền nhưng có XTRA -> tạo link mới)
--    / SKIP (crawler xác nhận 0 XTRA) / NEED_CRAWL (chưa đủ dữ liệu để kết luận).
-- =====================================================================
begin;

-- Trạng thái coi là "đang hoạt động" (tính tiền): Completed + Pending.
create or replace function public.aff_is_active(p_status text) returns boolean
  language sql immutable as $$
    select p_status in ('Completed','Hoàn thành','Pending','Đang chờ xử lý')
  $$;

-- View gốc: 1 dòng / LINK (item_id), đã enrich metadata crawler.
create or replace view public.aff_link_stats as
with base as (
  select
    o.item_id,
    (array_agg(o.item_name order by o.order_time desc))[1]   as item_name,
    (array_agg(o.l1_category order by o.order_time desc))[1] as l1_category,
    (array_agg(o.shop_name order by o.order_time desc))[1]   as shop_name,
    (array_agg(o.shop_id order by o.order_time desc))[1]     as shop_id,
    count(*)                                                  as orders_all,
    count(*) filter (where public.aff_is_active(o.order_status)) as orders_active,
    count(*) filter (where o.item_total_comm > 0)             as orders_earning,
    count(*) filter (where o.order_status in ('Cancelled','Đã hủy','Canceled')) as orders_cancelled,
    count(distinct o.account_id)                              as n_accounts_any,
    count(distinct o.account_id) filter (where o.item_total_comm > 0) as n_accounts_earning,
    coalesce(sum(o.item_total_comm) filter (where o.order_status in ('Completed','Hoàn thành')),0) as money_completed,
    coalesce(sum(o.item_total_comm) filter (where o.order_status in ('Pending','Đang chờ xử lý')),0) as money_pending,
    coalesce(sum(o.item_total_comm) filter (where public.aff_is_active(o.order_status)),0) as money,
    coalesce(sum(o.refund_amount),0)                          as refund,
    max(o.item_seller_comm_rate)                              as report_rate
  from public.affiliate_orders o
  group by o.item_id
)
select
  b.*,
  p.itemid is not null                                       as in_crawler,
  p.seller_commission                                        as crawler_seller_comm,
  -- rate THẬT: ưu tiên crawler (>0), fallback report, mặc định 0
  coalesce(nullif(p.seller_commission, 0), b.report_rate, 0) as rate_true,
  round(100.0 * b.orders_cancelled / nullif(b.orders_all, 0), 1) as cancel_pct,
  case
    when b.money > 0                                              then 'PHU'
    when coalesce(nullif(p.seller_commission,0), b.report_rate,0) > 0 then 'HUNT'
    when p.itemid is not null                                     then 'SKIP'        -- crawler có SP, seller_comm=0
    else 'NEED_CRAWL'                                                                -- chưa đủ dữ liệu -> cần crawl xác nhận
  end                                                          as link_class
from base b
left join public.products p on p.itemid = b.item_id;

-- ── DANH SÁCH PHỦ: link có tiền + gap độ phủ, xếp theo tiềm năng nhân rộng ──
-- projected_upside = (tiền TB/account đang ăn) × (số account còn thiếu), có trọng số chất lượng.
create or replace function public.aff_distribution_list(p_limit int default 200)
returns table (
  item_id text, item_name text, l1_category text, shop_name text,
  money numeric, orders_earning bigint, n_accounts_earning bigint,
  n_accounts_total bigint, gap int, cancel_pct numeric, distribution_priority numeric
)
language sql stable security definer set search_path to 'public' as $$
  with tot as (select count(*)::int n from public.affiliate_accounts)
  select
    s.item_id, s.item_name, s.l1_category, s.shop_name,
    s.money, s.orders_earning, s.n_accounts_earning,
    tot.n, greatest(tot.n - s.n_accounts_earning, 0) as gap,
    s.cancel_pct,
    round(
      (s.money / nullif(s.n_accounts_earning,0))
      * greatest(tot.n - s.n_accounts_earning, 0)
      * (1 - coalesce(s.cancel_pct,0)/100.0)
    ) as distribution_priority
  from public.aff_link_stats s, tot
  where s.link_class = 'PHU'
  order by distribution_priority desc nulls last, s.money desc
  limit p_limit;
$$;

-- ── DANH SÁCH SĂN LINK MỚI: SP có cầu + có XTRA nhưng CHƯA ăn tiền ──
create or replace function public.aff_hunt_list(p_limit int default 200)
returns table (
  item_id text, item_name text, l1_category text, shop_name text,
  orders_all bigint, rate_true numeric, in_crawler boolean, cancel_pct numeric, demand_score numeric
)
language sql stable security definer set search_path to 'public' as $$
  select
    s.item_id, s.item_name, s.l1_category, s.shop_name,
    s.orders_all, s.rate_true, s.in_crawler, s.cancel_pct,
    round(s.orders_all * s.rate_true * (1 - coalesce(s.cancel_pct,0)/100.0)) as demand_score
  from public.aff_link_stats s
  where s.link_class = 'HUNT'
  order by demand_score desc nulls last, s.orders_all desc
  limit p_limit;
$$;

grant select on public.aff_link_stats to service_role;
grant execute on function public.aff_is_active(text) to service_role, authenticator;
grant execute on function public.aff_distribution_list(int) to service_role;
grant execute on function public.aff_hunt_list(int) to service_role;

commit;
