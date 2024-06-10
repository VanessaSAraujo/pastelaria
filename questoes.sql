#1. Liste os nomes de todos os pastéis veganos vendidos para pessoas com mais de 18 anos.

SELECT  p.nome 
FROM produtos p
JOIN itens_pedidos ip ON p.produto_id = ip.produto_id 
JOIN pedidos pe ON ip.pedido_id = pe.pedido_id 
JOIN clientes cl ON pe.cliente_id = cl.cliente_id 
WHERE p.categoria_id = 2 
AND TIMESTAMPDIFF(YEAR, cl.data_nascimento, NOW()) > 17;


#2. Liste os clientes com maior número de pedidos realizados em 1 ano agrupados por mês

SELECT 
    c.nome_completo,
    COUNT(p.pedido_id) AS total_pedidos
FROM 
    clientes c
JOIN 
    pedidos p ON c.cliente_id = p.cliente_id
WHERE 
    p.data_pedido >= CURDATE() - INTERVAL 1 YEAR
GROUP BY 
    c.nome_completo, MONTH(p.data_pedido)
ORDER BY 
    total_pedidos DESC;




#3. Liste todos os pastéis que possuem bacon e/ou queijo em seu recheio.

SELECT DISTINCT p.nome AS pastel
FROM produtos p
JOIN pasteis_recheios pr ON p.produto_id = pr.pastel_id
JOIN recheios r ON pr.recheio_id = r.recheio_id
WHERE r.nome LIKE '%bacon%' OR r.nome LIKE '% queijo mussarela%';



#4. Mostre o valor de venda total de todos os pastéis cadastrados no sistema.

SELECT SUM(quantidade * preco) AS valor_total_vendas_pasteis
FROM itens_pedidos
WHERE produto_id BETWEEN 1 AND 72;

#5. Liste todos os pedidos onde há pelo menos um pastel e uma bebida.

SELECT DISTINCT pe.pedido_id
FROM pedidos pe
JOIN itens_pedidos ip1 ON pe.pedido_id = ip1.pedido_id
JOIN produtos p1 ON ip1.produto_id = p1.produto_id
JOIN itens_pedidos ip2 ON pe.pedido_id = ip2.pedido_id
JOIN produtos p2 ON ip2.produto_id = p2.produto_id
JOIN categorias c1 ON p1.categoria_id = c1.categoria_id
JOIN categorias c2 ON p2.categoria_id = c2.categoria_id
WHERE c1.nome  LIKE 'Pastéis%' AND c2.nome = 'Bebidas';

#6. Liste quais são os pastéis mais vendidos, incluindo a quantidade de vendas em ordem decrescente.

SELECT p.nome AS pastel, COUNT(ip.produto_id) AS quantidade_vendida
FROM itens_pedidos ip
JOIN produtos p ON ip.produto_id = p.produto_id
GROUP BY p.nome
ORDER BY quantidade_vendida DESC;


#7. Crie pelo menos 3 procedures

DELIMITER $

CREATE PROCEDURE adicionar_cliente(
    IN new_nome_completo VARCHAR(255),
    IN new_cpf CHAR(11),
    IN new_data_nascimento DATE,
    IN new_telefone VARCHAR(20),
    IN new_email VARCHAR(255),
    IN new_endereco INT
)
BEGIN
    INSERT INTO clientes (nome_completo, cpf, data_nascimento, telefone, email, endereco)
    VALUES (new_nome_completo, new_cpf, new_data_nascimento, new_telefone, new_email, new_endereco);
END $

DELIMITER ;

DELIMITER $

CREATE PROCEDURE novo_pedido(
    IN new_cliente_id INT,
    IN new_data_pedido DATE,
    IN new_forma_pagamento VARCHAR(50)
)
BEGIN
    INSERT INTO pedidos (cliente_id, data_pedido, forma_pagamento)
    VALUES (new_cliente_id, new_data_pedido, new_forma_pagamento);
END $

DELIMITER ;

DELIMITER $

CREATE PROCEDURE listar_pedidos_cliente(
    IN new_cliente_id INT
)
BEGIN
    SELECT * FROM pedidos
    WHERE cliente_id = new_cliente_id;
END $

DELIMITER ;


#8. Crie pelo menos 3 funções

DELIMITER $

CREATE FUNCTION calcular_total_pedido(pedido_id INT)
RETURNS DECIMAL(10,2)
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(preco * quantidade) INTO total
    FROM itens_pedidos
    WHERE pedido_id = pedido_id;
    RETURN total;
END $

DELIMITER ;

DELIMITER $

CREATE FUNCTION CalcularNumeroPedidosCliente(cliente_id INT)
RETURNS INT
BEGIN
    DECLARE num_pedidos INT;
    SELECT COUNT(*) INTO num_pedidos
    FROM pedidos
    WHERE cliente_id = cliente_id;
    RETURN num_pedidos;
END $

DELIMITER ;

DELIMITER $

CREATE FUNCTION CalcularTotalGastoCliente(cliente_id INT)
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(ip.quantidade * p.preco) INTO total
    FROM itens_pedidos ip
    INNER JOIN produtos p ON ip.produto_id = p.id
    INNER JOIN pedidos ped ON ip.pedido_id = ped.id
    WHERE ped.cliente_id = cliente_id;
    RETURN total;
END $

DELIMITER ;
#9. Crie pelo menos 5 gatilhos

DELIMITER $

CREATE TRIGGER atualizar_total_itens_pedido
AFTER INSERT ON itens_pedidos
FOR EACH ROW
BEGIN
    DECLARE total_itens INT;
    SELECT SUM(quantidade) INTO total_itens FROM itens_pedidos WHERE pedido_id = NEW.pedido_id;
    UPDATE pedidos SET total_itens = total_itens WHERE pedido_id = NEW.pedido_id;
END$

DELIMITER ;

DELIMITER $

CREATE TRIGGER validar_data_nascimento_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
    IF NEW.data_nascimento >= CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data de nascimento deve ser no passado.';
    END IF;
END$

DELIMITER ;

DELIMITER $

CREATE TRIGGER atualizar_preco_total_pedido
AFTER INSERT ON itens_pedidos
FOR EACH ROW
BEGIN
    DECLARE preco_total DECIMAL(10,2);
    SELECT SUM(preco * quantidade) INTO preco_total FROM itens_pedidos WHERE pedido_id = NEW.pedido_id;
    UPDATE pedidos SET preco_total = preco_total WHERE pedido_id = NEW.pedido_id;
END$

DELIMITER ;

DELIMITER $

CREATE TRIGGER validar_preco_produto
BEFORE INSERT ON produtos
FOR EACH ROW
BEGIN
    IF NEW.preco < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O preço do produto não pode ser negativo.';
    END IF;
END$

DELIMITER ;

DELIMITER $

CREATE TRIGGER check_quantidade_item_pedido
BEFORE INSERT ON itens_pedidos
FOR EACH ROW
BEGIN
    IF NEW.quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A quantidade do item deve ser maior que zero.';
    END IF;
END$

DELIMITER ;

#10. Crie pelo menos 10 views

#1
CREATE VIEW clientes_enderecos_view AS
SELECT 
    c.cliente_id,
    c.nome_completo,
    c.cpf,
    c.data_nascimento,
    c.telefone,
    c.email,
    e.bairro,
    e.cidade,
    e.estado
FROM 
    clientes c
JOIN 
    enderecos e ON c.endereco = e.id_endereco;

#2
CREATE VIEW pedidos_clientes_view AS
SELECT 
    p.pedido_id,
    p.data_pedido,
    p.forma_pagamento,
    c.cliente_id,
    c.nome_completo,
    c.telefone,
    c.email
FROM 
    pedidos p
JOIN 
    clientes c ON p.cliente_id = c.cliente_id;

#3
CREATE VIEW produtos_detalhes_view AS
SELECT 
    p.produto_id,
    p.nome,
    p.preco,
    p.tipo,
    t.nome AS tamanho,
    c.nome AS categoria
FROM 
    produtos p
LEFT JOIN 
    tamanhos t ON p.tamanho_id = t.tamanho_id
LEFT JOIN 
    categorias c ON p.categoria_id = c.categoria_id;

#4
CREATE VIEW pedidos_totais_view AS
SELECT 
    p.pedido_id,
    p.data_pedido,
    p.forma_pagamento,
    SUM(i.quantidade * i.preco) AS total_pedido
FROM 
    pedidos p
JOIN 
    itens_pedidos i ON p.pedido_id = i.pedido_id
GROUP BY 
    p.pedido_id;

#5
CREATE VIEW clientes_sem_pedidos_view AS
SELECT 
    c.cliente_id,
    c.nome_completo,
    c.cpf,
    c.data_nascimento,
    c.telefone,
    c.email
FROM 
    clientes c
LEFT JOIN 
    pedidos p ON c.cliente_id = p.cliente_id
WHERE 
    p.cliente_id IS NULL;

#6
CREATE VIEW recheios_view AS
SELECT 
    recheio_id,
    nome AS recheio_nome
FROM 
    recheios;

#7
CREATE VIEW categorias_view AS
SELECT 
    categoria_id,
    nome AS categoria_nome
FROM 
    categorias;

#8
CREATE VIEW clientes_com_mais_de_um_pedido_view AS
SELECT 
    c.cliente_id,
    c.nome_completo,
    COUNT(p.pedido_id) AS numero_de_pedidos
FROM 
    clientes c
JOIN 
    pedidos p ON c.cliente_id = p.cliente_id
GROUP BY 
    c.cliente_id
HAVING 
    COUNT(p.pedido_id) > 1;

#9
CREATE VIEW pedidos_com_numero_itens_view AS
SELECT 
    p.pedido_id,
    p.data_pedido,
    p.forma_pagamento,
    COUNT(i.item_id) AS numero_de_itens
FROM 
    pedidos p
JOIN 
    itens_pedidos i ON p.pedido_id = i.pedido_id
GROUP BY 
    p.pedido_id;

#10
CREATE VIEW produtos_nao_vendidos_view AS
SELECT 
    p.produto_id,
    p.nome,
    p.preco,
    p.tipo
FROM 
    produtos p
LEFT JOIN 
    itens_pedidos i ON p.produto_id = i.produto_id
WHERE 
    i.produto_id IS NULL;
