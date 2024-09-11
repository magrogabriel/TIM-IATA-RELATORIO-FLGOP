ALTER SESSION SET NLS_DATE_FORMAT='DD/MM/YYYY';


--Contagem de celulas com FLAGOPE 0 e 1 (diadatper deve ser o ultimo dia gerado o relatorio) 
SELECT COUNT(DESCEL) Contagem, DATA, FLGOPE FROM (
SELECT distinct(c.descel) DESCEL, a.flgope FLGOPE, a.diadatper DATA FROM <schema>.<table> A LEFT JOIN <schema>.<table> C ON A.NUMCELDW0 = C.NUMCELDW0 WHERE diadatper >=  to_date('20240827','RRRRMMDD')
UNION
SELECT distinct(c.descel) DESCEL, a.flgope FLGOPE, a.diadatper DATA FROM <schema>.<table> A LEFT JOIN <schema>.<table> C ON A.NUMCELDW0 = C.NUMCELDW0 WHERE diadatper >=  to_date('20240827','RRRRMMDD')
UNION
SELECT distinct(c.descel) DESCEL, a.flgope FLGOPE, a.diadatper DATA FROM <schema>.<table> A LEFT JOIN <schema>.<table> C ON A.NUMCELDW0 = C.NUMCELDW0 WHERE diadatper >=  to_date('20240827','RRRRMMDD')
UNION
SELECT distinct(c.descel) DESCEL, a.flgope FLGOPE, a.diadatper DATA FROM <schema>.<table> A LEFT JOIN <schema>.<table> C ON A.NUMCELDW0 = C.NUMCELDW0 WHERE diadatper >=  to_date('20240827','RRRRMMDD')
) 
GROUP BY DATA, FLGOPE
ORDER BY DATA, FLGOPE;


--Lista Celulas com FLAGOPE 0 no D-1 (diadatper deve ser o dia anterior ao da consulta)
SELECT DISTINCT(c.DESCEL), b.NUMSTATIONDW0, b.desbtsnod,  case when b.numtcndw0 =1 then '2G' when b.numtcndw0 = 2 then '3G' when b.numtcndw0 = 3 then '4G' when b.numtcndw0 = 22 then '5G' end as TECNOLOGIA, '02/09/2024' Data FROM 
(SELECT a.numbtsnoddw0, c.DESCEL FROM <schema>.<table> A LEFT JOIN <schema>.<table> C ON A.NUMCELDW0 = C.NUMCELDW0 WHERE diadatper =  to_date('20240902','RRRRMMDD') and a.flgope = 0
UNION
SELECT a.numbtsnoddw0, c.DESCEL FROM <schema>.<table> A LEFT JOIN <schema>.<table> C ON A.NUMCELDW0 = C.NUMCELDW0 WHERE diadatper =  to_date('20240902','RRRRMMDD') and a.flgope = 0
UNION
SELECT a.numbtsnoddw0, c.DESCEL FROM <schema>.<table> A LEFT JOIN <schema>.<table> C ON A.NUMCELDW0 = C.NUMCELDW0 WHERE diadatper =  to_date('20240902','RRRRMMDD') and a.flgope = 0
UNION
SELECT a.numbtsnoddw0, c.DESCEL FROM <schema>.<table> A LEFT JOIN <schema>.<table> C ON A.NUMCELDW0 = C.NUMCELDW0 WHERE diadatper =  to_date('20240902','RRRRMMDD') and a.flgope = 0
) C inner join <schema>.<table> b on c.numbtsnoddw0 = b.numbtsnoddw0
ORDER BY DATA, TECNOLOGIA;



--Contagem de celulas em WHITELIST (DT_SAIDA TEM QUE SER O D-1)
select count (distinct(DESCEL)) QTE_CELULAS, DIADATPER  from (SELECT descel,DT_ENTRADA,DT_SAIDA FROM <schema>.<table> 
WHERE ((DT_SAIDA >= TO_DATE('20240902','RRRRMMDD'))) group by descel,DT_ENTRADA,DT_SAIDA) A full outer join <schema>.<table> D on A.DT_ENTRADA <= D.DIADATPER AND A.DT_SAIDA >= D.DIADATPER 
where 1=1
and (mesdatper > 202407 and mesdatper < 202410)
GROUP BY DIADATPER order by diadatper;


-- Lista de celulas em WHITELIST no D-1
select * from (SELECT ct.desbtsnod SITE, ct.descel CELULA, ct.desvnd VENDOR, ct.numbnddw0 FREQUENCIA, ct.DT_ENTRADA, ct.DT_SAIDA, ct.DT_SAIDA_ANTERIOR, ct.SR , ct.CLASSIFICACAO, ct.MOTIVO, 
bs.EMAIL EMAIL_SOLICITANTE, bs.REGIONAL, bs.ORIGEMSERVICEREQUEST, 
bs.OPENINGMEMO, bs.DESCRICAO, bs.FUNCAO
FROM <schema>.<table> ct
LEFT JOIN <schema>.<table> bs
ON ct.SR = bs.ID_YEAR
WHERE nvl(ct.datfimvgn,trunc(sysdate)) = trunc(sysdate) and ct.dt_entrada < trunc(sysdate));


-- Contagem de celulas em BLACKLIST (DATLIBERACAOBLACKLIST TEM QUE SER MAIOR QUE A DATA LIMITE DA CONSULTA)
select count(distinct(descel)) QTE_CELULAS, DIADATPER FROM (SELECT descel,bl.DATINIVGN,BL.DATLIBERACAOBLACKLIST FROM <schema>.<table> BL INNER join <schema>.<table> c on bl.site = c.desbtsnod
WHERE bl.DATLIBERACAOBLACKLIST > TO_DATE('20240827','RRRRMMDD') AND BL.CODIBG <> 0 and c.datinivgn <= bl.datinivgn and nvl(c.datfimvgn,sysdate)>=bl.datinivgn  --and bl.site = '4G-PVOOJ1' --4G-CRBH66
group by bl.DATINIVGN,bl.DATLIBERACAOBLACKLIST,c.descel,bl.site) A full outer join <schema>.<table> D on A.DATINIVGN <= D.DIADATPER AND A.DATLIBERACAOBLACKLIST >= D.DIADATPER 
where 1=1
and (mesdatper > 202407 and mesdatper < 202410)
GROUP BY DIADATPER order by diadatper;


--Lista de celulas em BLACKLIST no D-1

SELECT bl.enderecoid,bl.site,c.descel,bl.tecn,bl.sigreg,bl.datinivgn,bl.datfimvgn,DATLIBERACAOBLACKLIST,bl.municipio,bl.codibg,bl.motivo,bl.plano_acao,bl.area_responsavel,bl.USUARIO_RESPONSAVEL
FROM <schema>.<table> BL 
INNER join <schema>.<table> c on bl.site = c.desbtsnod
inner join <schema>.<table> b on c.numbtsnoddw0 = b.numbtsnoddw0 
inner join <schema>.<table> tec on tec.numtcndw0 = b.numtcndw0 
WHERE BL.CODIBG <> 0  and  nvl(bl.datfimvgn,trunc(sysdate-1)) = trunc(sysdate-1) and nvl(c.datfimvgn,trunc(sysdate))>=bl.datinivgn and c.datinivgn <= bl.datinivgn and tec.sigtcn = bl.tecn
group by bl.enderecoid,bl.site,c.descel,bl.tecn,bl.sigreg,bl.datinivgn,bl.datfimvgn,DATLIBERACAOBLACKLIST,bl.municipio,bl.codibg,bl.motivo,bl.plano_acao,bl.area_responsavel,bl.USUARIO_RESPONSAVEL;
