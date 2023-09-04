
/****** Analysing the Sales data of AdventureWork  ******/


--Find the list of Products with it's SalesAmount and the % of contribution of each product towards the Total sales 

 Select 
  *, 
  T.TotalSales / SUM(T.Totalsales) over() * 100 as Contribution 
from 
  (
    Select 
      p.EnglishProductName as Product, 
      ROUND(
        SUM(S.salesamount), 
        2
      ) as TotalSales 
    From 
      FactInternetSales s 
      Left join DimProduct p on s.ProductKey = p.ProductKey 
    Group by 
      p.EnglishProductName
  ) as T 
order by 
  Contribution desc

--Find the Latest order of each of the Product

 Select 
  * 
from 
  (
    select 
      *, 
      ROW_NUMBER() over(
        partition by ProductKey 
        order by 
          OrderDate Desc
      ) as Rn 
    From 
      FactInternetSales
  ) as T 
where 
  T.Rn = 1


-- Find YTD Running Total
Select 
  *, 
  SUM(TotalSales) over(
    partition by YearOfOrder 
    Order by 
      OrderDate
  ) as YTDSales 
from 
  (
    Select 
      *, 
      Year(OrderDate) as YearOfOrder 
    from 
      (
        Select 
          OrderDate, 
          Round(
            SUM(SalesAmount), 
            2
          ) as TotalSales 
        From 
          FactInternetSales 
        Group by 
          OrderDate
      ) as T
  ) as T2

  --Find the % of Growth by comparing Current Year Sales with Previous Year Sales

  Select 
  *, 
  Round((Total / PrevYrSale),2) -1 as GrowthPercentage 
from 
  (
    select 
      *, 
      LAG(Total) Over(
        Order by 
          Year
      ) as PrevYrSale 
    from 
      (
        select 
          YEAR(OrderDate) as Year, 
          Round(SUM(SalesAmount),2) as Total 
        from 
          FactInternetSales 
        group by 
          YEAR(OrderDate)
      ) as T
  ) as T1

