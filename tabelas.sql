CREATE DATABASE pastelaria_do_beicola;
#DROP DATABASE pastelaria_do_beicola;

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

#Tabela categorias

CREATE TABLE categorias (
    categoria_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);

#Tabela tamanhos

CREATE TABLE tamanhos (
    tamanho_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);

#Tabela produtos

CREATE TABLE produtos (
    produto_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    tamanho_id INT,
    categoria_id INT,
    FOREIGN KEY (tamanho_id) REFERENCES tamanhos(tamanho_id),
    FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id)
);

#Tabela itens pedidos

CREATE TABLE  itens_pedidos(
	item_id INT PRIMARY KEY AUTO_INCREMENT,
	pedido_id INT NOT NULL,
	produto_id INT NOT NULL,
	quantidade INT NOT NULL,
	preco DECIMAL(10,2),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
    FOREIGN KEY (produto_id) REFERENCES produtos(produto_id)
);

#Tabela recheios

CREATE TABLE recheios (
    recheio_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);


# tabela pasteis recheios

CREATE TABLE pasteis_recheios (
    pastel_id INT,
    recheio_id INT,
    PRIMARY KEY (pastel_id, recheio_id),
    FOREIGN KEY (pastel_id) REFERENCES produtos(produto_id),
    FOREIGN KEY (recheio_id) REFERENCES recheios(recheio_id)
);
