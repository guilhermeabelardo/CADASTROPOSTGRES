
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;



CREATE FUNCTION public.registrar_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_operacoes (tipo_operacao) VALUES ('INSERT');
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO log_operacoes (tipo_operacao) VALUES ('UPDATE');
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO log_operacoes (tipo_operacao) VALUES ('DELETE');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.registrar_log() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;



CREATE TABLE public.cadastro (
    id integer NOT NULL,
    campo_texto character varying(100) NOT NULL,
    campo_numerico integer NOT NULL,
    CONSTRAINT cadastro_campo_numerico_check CHECK ((campo_numerico > 0))
);


ALTER TABLE public.cadastro OWNER TO postgres;

CREATE SEQUENCE public.cadastro_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cadastro_id_seq OWNER TO postgres;


ALTER SEQUENCE public.cadastro_id_seq OWNED BY public.cadastro.id;



CREATE TABLE public.log_operacoes (
    id integer NOT NULL,
    data_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tipo_operacao character varying(10) NOT NULL,
    CONSTRAINT log_operacoes_tipo_operacao_check CHECK (((tipo_operacao)::text = ANY ((ARRAY['INSERT'::character varying, 'UPDATE'::character varying, 'DELETE'::character varying])::text[])))
);


ALTER TABLE public.log_operacoes OWNER TO postgres;



CREATE SEQUENCE public.log_operacoes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_operacoes_id_seq OWNER TO postgres;


ALTER SEQUENCE public.log_operacoes_id_seq OWNED BY public.log_operacoes.id;



ALTER TABLE ONLY public.cadastro ALTER COLUMN id SET DEFAULT nextval('public.cadastro_id_seq'::regclass);



ALTER TABLE ONLY public.log_operacoes ALTER COLUMN id SET DEFAULT nextval('public.log_operacoes_id_seq'::regclass);



COPY public.cadastro (id, campo_texto, campo_numerico) FROM stdin;
\.




COPY public.log_operacoes (id, data_hora, tipo_operacao) FROM stdin;
1	2025-08-14 00:53:11.159308	INSERT
2	2025-08-14 00:53:17.774264	DELETE
3	2025-08-14 00:54:20.988341	INSERT
4	2025-08-14 01:08:14.345997	DELETE
5	2025-08-14 01:17:43.829913	INSERT
6	2025-08-14 01:17:46.575737	DELETE
7	2025-08-14 01:20:34.31233	INSERT
8	2025-08-14 01:20:44.377808	DELETE
\.




SELECT pg_catalog.setval('public.cadastro_id_seq', 4, true);



SELECT pg_catalog.setval('public.log_operacoes_id_seq', 8, true);



ALTER TABLE ONLY public.cadastro
    ADD CONSTRAINT cadastro_campo_numerico_key UNIQUE (campo_numerico);




ALTER TABLE ONLY public.cadastro
    ADD CONSTRAINT cadastro_pkey PRIMARY KEY (id);



ALTER TABLE ONLY public.log_operacoes
    ADD CONSTRAINT log_operacoes_pkey PRIMARY KEY (id);



CREATE TRIGGER trigger_log_cadastro AFTER INSERT OR DELETE OR UPDATE ON public.cadastro FOR EACH ROW EXECUTE FUNCTION public.registrar_log();



