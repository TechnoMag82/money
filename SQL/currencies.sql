--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2 (Ubuntu 16.2-1.pgdg20.04+1)
-- Dumped by pg_dump version 16.2 (Ubuntu 16.2-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: banks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.banks (
    id integer NOT NULL,
    bank_id integer NOT NULL,
    country character varying(8) COLLATE pg_catalog."ru_RU",
    bank_name character varying(100) COLLATE pg_catalog."ru_RU"
);


--
-- Name: banks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.banks ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.banks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: currencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currencies (
    id integer NOT NULL,
    currency_name_id integer NOT NULL,
    bank_id integer NOT NULL,
    buy real NOT NULL,
    sell real NOT NULL,
    date_get date NOT NULL
);


--
-- Name: currencies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.currencies ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.currencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: currency_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.currency_names (
    id integer NOT NULL,
    currency_name character varying(10) NOT NULL
);


--
-- Name: currency_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.currency_names ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.currency_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: get_banks; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.get_banks AS
 SELECT bank_id,
    bank_name
   FROM public.banks;


--
-- Name: get_banks_currency; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.get_banks_currency AS
 SELECT b.bank_id,
    b.bank_name,
    c.buy,
    c.sell,
    c.date_get,
    cn.currency_name
   FROM ((public.currencies c
     JOIN public.currency_names cn ON ((cn.id = c.currency_name_id)))
     JOIN public.banks b ON ((b.bank_id = c.bank_id)));


--
-- Name: get_base_statistic; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.get_base_statistic AS
 SELECT cn.id,
    cn.currency_name,
    cr.avg_buy,
    cr.avg_sell,
    cr.min_buy,
    cr.min_sell,
    cr.max_buy,
    cr.max_sell,
    cr.currency_name_id
   FROM (public.currency_names cn
     JOIN ( SELECT avg(currencies.buy) AS avg_buy,
            avg(currencies.sell) AS avg_sell,
            min(currencies.buy) AS min_buy,
            min(currencies.sell) AS min_sell,
            max(currencies.buy) AS max_buy,
            max(currencies.sell) AS max_sell,
            currencies.currency_name_id
           FROM public.currencies
          WHERE (currencies.date_get = CURRENT_DATE)
          GROUP BY currencies.currency_name_id) cr ON ((cn.id = cr.currency_name_id)));


--
-- Name: get_currency_names; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.get_currency_names AS
 SELECT currency_name
   FROM public.currency_names cn;


--
-- Name: banks banks_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.banks
    ADD CONSTRAINT banks_pk PRIMARY KEY (id);


--
-- Name: currencies currencies_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currencies
    ADD CONSTRAINT currencies_pk PRIMARY KEY (id);


--
-- Name: currency_names currency_names_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.currency_names
    ADD CONSTRAINT currency_names_pk PRIMARY KEY (id);


--
-- Name: banks_bank_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX banks_bank_id_idx ON public.banks USING btree (bank_id, bank_name);


--
-- Name: currencies_date_get_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX currencies_date_get_idx ON public.currencies USING btree (date_get, bank_id, currency_name_id);


--
-- Name: currency_names_currency_name_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX currency_names_currency_name_idx ON public.currency_names USING btree (currency_name);


--
-- PostgreSQL database dump complete
--

