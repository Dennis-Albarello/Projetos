/* Essas queries foram desenvolvidas ao longo do aprendizado durante curso na UDEMY desenvolvido pela Midori Toyota */
/* https://www.udemy.com/share/106ct83@TvFcQ6c9LLmQlU5iv24zJz_1VGFnEh9ahY0bbTwoJYV2FqH2bweDKDe534TU4e-bNg==/ */

-- Esse curso foi realizado utilizando o PostgreSQL, mas na oportunidad realizei meu estudo utilizando o MySQL. 

-- ######################################################################################################## --
-- (Query 1) Identificando a Receita, os leads, conversão e ticket médio mês a mês

-- Criando uma Tabela Temporária com a quantidade de visitas ao site
DROP TEMPORARY TABLE IF EXISTS visitas;

CREATE TEMPORARY TABLE visitas
SELECT
	DATE_FORMAT(visit_page_date , '%Y/%m') AS ano_mes,
	count(visit_page_date) AS leads
FROM
	sales.funnel
GROUP BY
	ano_mes
ORDER BY
	ano_mes asc;

-- Criando uma Tabela Temporária com os dados financeiros
DROP TEMPORARY TABLE IF EXISTS financeiro;

CREATE TEMPORARY TABLE financeiro
SELECT
	DATE_FORMAT(fun.paid_date , '%Y/%m') AS ano_mes,
	count(fun.paid_date) as vendas,
	sum(pro.price * (1 + fun.discount)) AS receita
FROM
	sales.funnel AS fun
	LEFT JOIN sales.products AS pro
		ON fun.product_id = pro.product_id
WHERE
	fun.paid_date IS NOT NULL
GROUP BY
	ano_mes
ORDER BY
	ano_mes asc;

-- Realizando a consulta com a utilização das duas Tabelas Temporárias criadas anteriormente
SELECT
	visitas.ano_mes AS 'mês',
	visitas.leads AS 'leads (#)',
	financeiro.vendas AS 'vendas (#)',
	financeiro.receita / 1000 AS 'receita (k , R$)',
	round((financeiro.vendas / visitas.leads),4) AS 'conversao',
	round((financeiro.receita / financeiro.vendas) / 1000 , 2) AS 'ticket_medio (k , R$)'
FROM
	visitas
	LEFT JOIN financeiro
		ON visitas.ano_mes = financeiro.ano_mes
GROUP BY
	visitas.ano_mes,
	visitas.leads,
	financeiro.vendas,
	financeiro.receita;

-- ######################################################################################################## --
-- (Query 2) Estados que mais venderam no último mês. Na época era o mês de Agosto (08).

-- Adicionando uma nova coluna na Tabela
ALTER TABLE sales.customers
ADD country VARCHAR(10);

UPDATE sales.customers
SET country = 'Brasil'
WHERE True;

SELECT
	country as 'país',
	state as 'estado',
	count(t2.paid_date) as vendas
FROM sales.customers as t1
	LEFT JOIN sales.funnel as t2
	ON t1.customer_id = t2.customer_id
WHERE
	t2.paid_date BETWEEN '2021-08-01' AND '2021-08-31'
GROUP BY
	country,
	state;

-- ######################################################################################################## --
-- (Query 3) Identificando as 5 Marcas que mais venderam no último mês. Na época era o mês de Agosto (08).

SELECT 
	pro.brand as marca,
	count(fun.paid_date) as 'vendas (#)'
FROM
	sales.products AS pro
		LEFT JOIN sales.funnel AS fun
		ON pro.product_id = fun.product_id
WHERE
	fun.paid_date BETWEEN '2021-08-01' AND '2021-08-31'
GROUP BY
	pro.brand
ORDER BY
	count(fun.paid_date) DESC
LIMIT 5;

-- ######################################################################################################## --
-- (Query 4) Identificando quais foram as lojas que mais venderam no último mês. Na época era o mês de Agosto (08).

SELECT 
	sto.store_name as loja,
	count(fun.paid_date) as 'vendas (#)'
FROM
	sales.stores AS sto
		LEFT JOIN sales.funnel AS fun
		ON sto.store_id = fun.store_id
WHERE
	fun.paid_date BETWEEN '2021-08-01' AND '2021-08-31'
GROUP BY
	loja
ORDER BY
	count(fun.paid_date) DESC
LIMIT 5;

-- ######################################################################################################## --
-- (Query 5) Identificando quais dias da semana com maior número de visitas ao site no último mês. Na época era o mês de Agosto (08).

SELECT
	dayofweek(visit_page_date) as 'dia_semana',
	date_format(visit_page_date , '%W' ) as 'dia da semana',
	count(*) as 'visitas (#)'
FROM
	funnel
WHERE
	visit_page_date BETWEEN '2021-08-01' AND '2021-08-31'
GROUP BY
	dayofweek(visit_page_date), 
	date_format(visit_page_date , '%W' )
ORDER BY
	dayofweek(visit_page_date);

