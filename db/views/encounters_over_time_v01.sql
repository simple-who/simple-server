-- Only most recent Encounter per patient per month. Encounters are ordered appropriately below.
SELECT
    DISTINCT ON (e.patient_id, cal.month_date)
    cal.month_date,
    cal.month,
    cal.quarter,
    cal.year,
    e.encountered_on AS encountered_at,
    p.recorded_at AS patient_registered_at,
    e.id AS encounter_id,
    e.patient_id,
    p.assigned_facility_id AS patient_assigned_facility_id,
    p.registration_facility_id AS patient_registration_facility_id,
    e.facility_id AS encounter_facility_id,

    date_part('year', age(p.recorded_at, cal.month_date)) * 12 +
    date_part('month', age(p.recorded_at, cal.month_date))
    AS months_since_registration,

    date_part('year', age(e.encountered_on, cal.month_date)) * 12 +
    date_part('month', age(e.encountered_on, cal.month_date))
    AS months_since_encounter

FROM encounters e
-- Only fetch Encounters that happened on or before the selected calendar month
-- We use year and month comparisons to avoid timezone errors
LEFT OUTER JOIN calendar_months cal
    ON to_char(e.encountered_on AT TIME ZONE 'utc' AT TIME ZONE (SELECT current_setting('TIMEZONE')), 'YYYY-MM') <= to_char(cal.month_date, 'YYYY-MM')
INNER JOIN patients p
    ON e.patient_id = p.id
-- Ensure most recent Encounter is fetched
ORDER BY
    e.patient_id,
    cal.month_date,
    e.encountered_on DESC