CREATE TABLE Aeronaves(
	id SERIAL PRIMARY KEY,
	modelo VARCHAR(150) NOT NULL,
	codigo_cauda VARCHAR(10) UNIQUE NOT NULL,
	capacidade INT NOT NULL CHECK (capacidade >=0)
)

CREATE TABLE Pilotos(
	id SERIAL PRIMARY KEY,
	nome NOT NULL,
	codigo_anac VARCHAR(6) UNIQUE NOT NULL,
	horas_voo INT DEFAULT(0) NOT NULL CHECK(horas_voo >=0)
)

CREATE TABLE voos(
	id SERIAL PRIMARY KEY,
	aeronave_id INT NOT NULL REFERENCES aeronaves(id),
	piloto_id INT NOT NULL REFERENCES pilotos(id),
	numero_voo VARCHAR(150) NOT NULL,
	origem VARCHAR(150) NOT NULL,
	destino VARCHAR(150) NOT NULL,
	data_hora TIMESTAMP DEFAULT(CURRENT_TIMESTAMP),
	status 
)

CREATE TABLE Passageros(
	id SERIAL PRIMARY KEY,
 	nome VARCHAR(150) NOT NULL,
 	cpf VARCHAR(11) UNIQUE NOT NULL,
	email VARCHAR(150) UNIQUE NOT NULL
)

CREATE TABLE Passagens(
	id SERIAL PRIMARY KEY,
	voo_id INT NOT NULL REFERENCES voo(id),
	passageiro_id INT NOT NULL REFERENCES passageiro(id),
	assento VARCHAR(4) NOT NULL,
	classe
	valor
)



INSERT INTO Aeronaves (nomodelo, codigo_cauda, capacidade) VALUES
('tututumsaur', 'fdf-434', 99),
('bailarinacapuchina', 'kjd-147', 150),
('pimpimsatapim', '	sid-987', 24),
('kinjhonhum', 'sdh-273', 27),
('sixseven', 'kls-167', 67);

INSERT INTO Piloto (nome, codigo_anac, horas_voo) VALUES
('Roby', 'FGIDTJ', 1258),
('Anapaula', 'OÇDGH', 150),
('Mariana', 'KIHSFI', 563),
('Pietra', 'ÇIAUFD', 836),
('Henrique', 'LSHDFG', 666);

INSERT INTO voos (aeronave_id, piloto_id, numero_voo, origem, destino, status) VALUES
(1, 1, 16, 'haskapusca', 'paraguai', '')
(2, 2, 44, 'uberlandia', 'taxilândia', ''),
(3, 3, 55, 'barra da lagoa', 'sergipe', ''),
(4, 4, 98, 'joaçaba', 'chapecó', ''),
(5, 5, 73, 'groelandia', 'amapá', '');

INSERT INTO passageiros (nome, cpf, email) VALUES
('Sofia', 97327346625, 'Sofia@gamil.com')
('Ana', 74829478174, 'Ana@gamil.com'),
('Henrique', 83038163697, 'henrique@gamil.com'),
('Pietra', 98204816462, 'Pietra@gamil.com'),
('fabricia', 59638521973, 'Fabricia@gamil.com');

INSERT INTO passagens (voo_id, passageiro_id, assento, classe, valor) VALUES
(1, 1, 14, '', '')
(2, 2, 16, '', ''),
(3, 3, 44, '', ''),
(4, 4, 37, '', ''),
(5, 5, 66, '', '');
