INSERT INTO currencies
    (currency_name_id,
    bank_id,
    buy,
    sell,
    date_get)
VALUES ((SELECT id FROM currency_names WHERE currency_name = 'USD'),
    1,
    33.0,
    40.004,
    current_date)
ON CONFLICT (date_get, bank_id, currency_name_id)
DO UPDATE
SET
    buy = EXCLUDED.buy,
    sell = EXCLUDED.sell;