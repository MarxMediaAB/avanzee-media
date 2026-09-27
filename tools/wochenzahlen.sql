-- Wochenzahlen Lead Magnet avanzee.com/lt. Im Supabase SQL-Editor ausfuehren.
-- Eine Zeile pro Kalenderwoche (Montag), letzte 8 Wochen.
select
  to_char(date_trunc('week', d), 'YYYY-MM-DD') as woche_ab,
  (select count(*) from public.guide_requests g
     where g.source = 'lt' and g.pdf_sent_at >= date_trunc('week', d)
       and g.pdf_sent_at < date_trunc('week', d) + interval '7 days') as workbook_gesendet,
  (select count(*) from public.newsletter_subscribers n
     where n.source = 'lt' and n.confirmed_at is not null and n.unsubscribed_at is null
       and n.confirmed_at >= date_trunc('week', d)
       and n.confirmed_at < date_trunc('week', d) + interval '7 days') as abonnenten_bestaetigt
from generate_series(date_trunc('week', now()) - interval '7 weeks', date_trunc('week', now()), interval '7 days') as d
order by woche_ab desc;
