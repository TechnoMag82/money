SELECT b.bank_name, c.buy, c.sell, c.date_get FROM currencies c
JOIN currency_names cn ON cn.id = c.currency_name_id 
JOIN banks b ON b.bank_id =c.bank_id
WHERE cn.currency_name = 'USD' AND c.date_get = current_date;
