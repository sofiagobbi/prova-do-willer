
-- =====================================================
-- PROJETO: GESTAO DE TORNEIOS E-SPORTS
-- SGBD: PostgreSQL
-- =====================================================

-- =====================================================
-- 1. CRIACAO DAS TABELAS (DDL)
-- =====================================================

CREATE TABLE jogadores (
    id_jogador SERIAL PRIMARY KEY,
    nickname VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ativo'
        CHECK (status IN ('ativo', 'inativo', 'banido')),
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE modalidades (
    id_modalidade SERIAL PRIMARY KEY,
    nome VARCHAR(60) NOT NULL UNIQUE,
    categoria VARCHAR(30) NOT NULL,
    descricao TEXT
);

CREATE TABLE partidas (
    id_partida SERIAL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    id_modalidade INTEGER NOT NULL,
    id_jogador_responsavel INTEGER NOT NULL,
    data_agendada TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'agendada'
        CHECK (status IN ('agendada', 'em andamento', 'concluida', 'cancelada')),
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_modalidade)
        REFERENCES modalidades(id_modalidade),

    FOREIGN KEY (id_jogador_responsavel)
        REFERENCES jogadores(id_jogador)
);

CREATE TABLE inscricoes (
    id_inscricao SERIAL PRIMARY KEY,
    id_jogador INTEGER NOT NULL,
    id_partida INTEGER NOT NULL,
    data_inscricao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'pendente'
        CHECK (status IN ('confirmada', 'pendente', 'cancelada')),

    UNIQUE (id_jogador, id_partida),

    FOREIGN KEY (id_jogador)
        REFERENCES jogadores(id_jogador),

    FOREIGN KEY (id_partida)
        REFERENCES partidas(id_partida)
);

CREATE TABLE historico_partidas (
    id_historico SERIAL PRIMARY KEY,
    id_partida INTEGER NOT NULL,
    evento VARCHAR(150) NOT NULL,
    data_evento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_partida)
        REFERENCES partidas(id_partida)
);


-- =====================================================
-- 2. INSERCAO DE DADOS (DML)
-- =====================================================

-- JOGADORES

INSERT INTO jogadores (nickname, email, senha, status)
VALUES
('ShadowBR', 'shadow@email.com', '123456', 'ativo'),
('NexusPlayer', 'nexus@email.com', '123456', 'ativo'),
('DarkWolf', 'darkwolf@email.com', '123456', 'banido'),
('FrostByte', 'frost@email.com', '123456', 'inativo'),
('LunarX', 'lunar@email.com', '123456', 'ativo');


-- MODALIDADES

INSERT INTO modalidades (nome, categoria, descricao)
VALUES
('Valorant', 'FPS', 'Jogo de tiro competitivo'),
('League of Legends', 'MOBA', 'Jogo de estrategia em equipe'),
('Rocket League', 'Esportivo', 'Jogo de futebol com carros'),
('Counter-Strike 2', 'FPS', 'Jogo de tiro tatico');


-- PARTIDAS

INSERT INTO partidas
(titulo, id_modalidade, id_jogador_responsavel, data_agendada, status)
VALUES
('ShadowBR vs NexusPlayer', 1, 1, CURRENT_TIMESTAMP + INTERVAL '2 days', 'agendada'),
('NexusPlayer vs LunarX', 2, 2, CURRENT_TIMESTAMP + INTERVAL '5 days', 'agendada'),
('DarkWolf vs FrostByte', 3, 3, CURRENT_TIMESTAMP + INTERVAL '1 day', 'agendada'),
('FrostByte vs ShadowBR', 4, 4, CURRENT_TIMESTAMP + INTERVAL '3 days', 'agendada');


-- INSCRICOES

INSERT INTO inscricoes (id_jogador, id_partida, status)
VALUES
(1, 1, 'confirmada'),
(2, 1, 'confirmada'),
(2, 2, 'confirmada'),
(5, 2, 'confirmada'),
(3, 3, 'pendente'),
(4, 3, 'confirmada'),
(4, 4, 'confirmada'),
(1, 4, 'confirmada');


-- HISTORICO

INSERT INTO historico_partidas (id_partida, evento)
VALUES
(1, 'Partida registrada no sistema'),
(2, 'Partida registrada no sistema'),
(3, 'Partida registrada no sistema');


-- =====================================================
-- 3. FUNCTION: BUSCAR JOGADORES
-- =====================================================

CREATE OR REPLACE FUNCTION fn_buscar_jogadores(termo TEXT)
RETURNS TABLE (
    id_jogador INTEGER,
    nickname VARCHAR,
    email VARCHAR,
    status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        j.id_jogador,
        j.nickname,
        j.email,
        j.status
    FROM jogadores j
    WHERE j.nickname ILIKE '%' || termo || '%'
       OR j.email ILIKE '%' || termo || '%';
END;
$$;


-- =====================================================
-- 4. TRIGGER: VALIDAR PARTIDA
-- =====================================================

CREATE OR REPLACE FUNCTION trg_validar_partida()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    -- Verifica se o jogador responsavel esta ativo
    IF NOT EXISTS (
        SELECT 1
        FROM jogadores
        WHERE id_jogador = NEW.id_jogador_responsavel
          AND status = 'ativo'
    ) THEN
        RAISE EXCEPTION 'Jogador inexistente, banido ou inativo';
    END IF;

    -- Define a data de criacao automaticamente
    NEW.data_criacao := CURRENT_TIMESTAMP;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_partida
BEFORE INSERT ON partidas
FOR EACH ROW
EXECUTE FUNCTION trg_validar_partida();


-- =====================================================
-- 5. VIEW: PAINEL PRINCIPAL
-- =====================================================

CREATE OR REPLACE VIEW vw_painel_principal AS
SELECT
    j.nickname,
    p.titulo AS partida,
    m.categoria,
    p.data_agendada,
    p.status
FROM partidas p
INNER JOIN jogadores j
    ON p.id_jogador_responsavel = j.id_jogador
INNER JOIN modalidades m
    ON p.id_modalidade = m.id_modalidade;


-- =====================================================
-- 6. VIEW: CRONOGRAMA DE PARTIDAS
-- =====================================================

CREATE OR REPLACE VIEW vw_cronograma_partidas AS
SELECT
    p.id_partida,
    p.titulo,
    j.nickname AS jogador_responsavel,
    p.data_agendada,
    p.status,
    (p.data_agendada::DATE - CURRENT_DATE) AS dias_restantes
FROM partidas p
INNER JOIN jogadores j
    ON p.id_jogador_responsavel = j.id_jogador
ORDER BY p.data_agendada ASC;


-- =====================================================
-- 7. CONSULTAS DE TESTE
-- =====================================================

-- Testar painel principal
SELECT * FROM vw_painel_principal;

-- Testar cronograma
SELECT * FROM vw_cronograma_partidas;

-- Testar busca de jogadores
SELECT * FROM fn_buscar_jogadores('Shadow');

-- Ver historico
SELECT * FROM historico_partidas;
