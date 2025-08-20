CREATE DATABASE teste_dev;
\c teste_dev;

CREATE TABLE cadastro (
    id SERIAL PRIMARY KEY,
    nome TEXT NOT NULL,
    numero INTEGER NOT NULL CHECK (numero > 0),
    UNIQUE (numero)
);

CREATE TABLE log_operacoes (
    id SERIAL PRIMARY KEY,
    operacao VARCHAR(10) NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT NOW(),
    id_cadastro INT,
    numero INT
);

CREATE OR REPLACE FUNCTION registrar_log() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO log_operacoes(operacao, id_cadastro, numero)
        VALUES ('INSERT', NEW.id, NEW.numero);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO log_operacoes(operacao, id_cadastro, numero)
        VALUES ('UPDATE', NEW.id, NEW.numero);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO log_operacoes(operacao, id_cadastro, numero)
        VALUES ('DELETE', OLD.id, OLD.numero);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cadastro_insert
AFTER INSERT ON cadastro
FOR EACH ROW EXECUTE FUNCTION registrar_log();

CREATE TRIGGER trg_cadastro_update
AFTER UPDATE ON cadastro
FOR EACH ROW EXECUTE FUNCTION registrar_log();

CREATE TRIGGER trg_cadastro_delete
AFTER DELETE ON cadastro
FOR EACH ROW EXECUTE FUNCTION registrar_log();
