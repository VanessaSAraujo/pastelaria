CREATE DATABASE pastelaria_do_beicola;

USE pastelaria_do_beicola;

# Tabela endereco

CREATE TABLE enderecos(
id_endereco INT PRIMARY KEY NOT NULL,
bairro VARCHAR(200) NOT NULL,
cidade VARCHAR(200) NOT NULL,
estado VARCHAR(2) NOT NULL
);

# Tabela cliente

 CREATE TABLE clientes (
    cliente_id INT PRIMARY KEY AUTO_INCREMENT,
    nome_completo VARCHAR(250) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE,
    telefone VARCHAR(15),
    email VARCHAR(255) UNIQUE,
    endereco INT NOT NULL,
    FOREIGN KEY (endereco) REFERENCES enderecos(id_endereco)
);

# Tabela pedidos

CREATE TABLE pedidos (
    pedido_id INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id INT,
    data_pedido DATE NOT NULL,
    forma_pagamento VARCHAR(50),
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);