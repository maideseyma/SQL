--23.03.2023 503 SQL 
-- örn: Hangi kitap kaç kere ödünç alýnmýþ
use OduncKitapDB
select k.KitapAdi , count(*) [Kaç Kere Ödünç Alýnmýþtýr?]
from OduncIslemler (nolock) odnc
join Kitaplar k (nolock) on k.Id= odnc.KitapId
group by k.KitapAdi

select k.KitapAdi , count(*) [Kaç Kere Ödünç Alýnmýþtýr?]
from Kitaplar k (nolock) 
join OduncIslemler odnc (nolock) on k.Id= odnc.KitapId
group by k.KitapAdi

--ÖRN: 1996 yýlýnda en az kazandýran çalýþaným
use NORTHWND
select  top 1 concat(e.FirstName ,' ', e.LastName) [Çalýþan] , 
count(*) [Satýþ Sayýsý]
from Orders o (nolock)
join Employees e (nolock) on e.EmployeeID=o.EmployeeID
where o.OrderDate >='19960101' and o.OrderDate <'19970101'
group by e.FirstName , e.LastName
order by [Satýþ Sayýsý] 


--ÖRN: 1997 yýlýnda kazancý min 7000 olup birim fiyatý min 20 ve içinde ff geçmeyen ürünlerden kazandýðým
select top 10 * from [Order Details]
select p.ProductName , sum(od.UnitPrice * od.Quantity * (1- od.Discount)) [Kazanç] 
from [Order Details] od (nolock)
join Orders o (nolock) on o.OrderID=od.OrderID
join Products p (nolock) on p.ProductID=od.ProductID
where od.UnitPrice >=20 and p.ProductName not like '%ff%'
and o.OrderDate >='19970101' and o.OrderDate <'19980101'
group by p.ProductName
having sum(od.UnitPrice * od.Quantity * (1- od.Discount))  >=7000

--cast komutu
select cast(13948.6799926758 as decimal(18,0))

select p.ProductName , cast(sum(od.UnitPrice * od.Quantity * (1- od.Discount)) as decimal(18,2)) [Kazanç] 
from [Order Details] od (nolock)
join Orders o (nolock) on o.OrderID=od.OrderID
join Products p (nolock) on p.ProductID=od.ProductID
where od.UnitPrice >=20 and p.ProductName not like '%ff%'
and o.OrderDate >='19970101' and o.OrderDate <'19980101'
group by p.ProductName
having sum(od.UnitPrice * od.Quantity * (1- od.Discount))  >=7000


---SELECT SORGUSUNUN ÇALIÞMA SIRASI
-- 1) FROM 
-- 1,5) Varsa join join çalýþýr yoksa 2'ye geç
-- 2) WHERE 
-- 3) Varsa Group by çalýþýr
-- 4) HAVING çalýþýr
-- 5) SELECT çalýþýr
-- 6) ORDER BY çalýþýr --> Alias kullanýlabilir (Select'ten sonra çalýþtýðý için)

-----------------------------------------------------------------------------
--delete iþlemi DML komutu
--> hard delete  --> delete komutunu yazarak tablodan o veriyi yok etmek / silmek
--> soft delete --> Tabloya SlindiMi/ AktifMi gibi kolonlar ekleyerek bu kolonlarý güncellemek
use OduncKitapDB
delete from Kitaplar where Id=67 --hard delete

update Kitaplar set SilindiMi=1 where Id=53 --> (soft delete) UPDATE ÝÞLEMÝDÝR

select * from Kitaplar where KitapAdi like '%cam%'

--case when then
--rownumber()
--order by
--aggregate functions
--group by having
--delete
--sub query
--deðiþken , döngü
--view
--stored function
--Trigger
-- Transaction 
-------------------------------------------------------------------------------
--View: Kod ile de oluþturulur. Object Explorer penceresinden Views >> New View ile designer penceresinden de oluþturulur.

create View KitapTurYazarView
as
select k.Id, k.KayitTarihi,k.KitapAdi, t.TurAdi,
concat(y.YazarAdi, ' ', y.YazarSoyadi) [Yazar], k.SayfaSayisi, k.StokAdeti,
k.ResimLink, k.SilindiMi
from Kitaplar k (nolock)
join Yazarlar y (nolock) on y.Id=k.YazarId
join Turler t (nolock) on t.Id=k.TurId
 use NORTHWND
alter view ProductCiro1997
as 
select   p.ProductID, p.ProductName , sum(od.UnitPrice * od.Quantity * (1- od.Discount)) [Kazanç] 
from [Order Details] od (nolock)
join Orders o (nolock) on o.OrderID=od.OrderID
join Products p (nolock) on p.ProductID=od.ProductID
where od.UnitPrice >=20 and p.ProductName not like '%ff%'
and o.OrderDate >='19970101' and o.OrderDate <'19980101'
group by p.ProductName, p.ProductID


use OduncKitapDB 
select * from KitapTurYazarView

-------------------------------------------------------------
--sub query: Alt sorgu anlamýna gelir. Ýç-içe select sorgusu  yazmaktýr.
--ÖRN: Shipper Speedy Express isimli kargoyla verilen sipariþler
use NORTHWND
select * from Orders o (nolock)
where o.ShipVia =
(select ShipperID from Shippers where CompanyName='Speedy Express')

-- Derived Türetilmiþ tablo :
--Parantez içine alýnan Altsorguya TAKMA ÝSÝM (alias) verilerek
--türetilmiþ tablo haline getirip kullanabilirsiniz.
--ÖRN: Kargoda 30 günü aþan sipariþler 

select * from
(
select o.OrderID, o.OrderDate, o.ShippedDate,
DATEDIFF(day, o.OrderDate, o.ShippedDate) [Kaç Günde Kargolandi?]
from Orders (nolock) o ) kargoGunleri
where [Kaç Günde Kargolandi?] >35

--ÖRN ***** 35 günü aþan kargoya verme iþlemi problem oluþturmakatadýr. (baþarýsýz gönderim iþlemi sayýlmaktadýr) Firmanýn yýl bazýnda kaç defa baþarýsýz gönderim iþlemi olmuþtur?

select year(kargoGunleri.OrderDate) Yýl , count(*) [Kaç Kere baþarýsýz gönderim iþlemi Olmuþ?]
from 
(select o.OrderID, o.OrderDate, o.ShippedDate,
DATEDIFF(day, o.OrderDate, o.ShippedDate) [Kaç Günde Kargolandi?]
from Orders (nolock) o 
where DATEDIFF(day, o.OrderDate, o.ShippedDate) > 35) kargoGunleri 
group by year(kargoGunleri.OrderDate)

-------------------------------------------------------------------
select yýlSonuc.OrderYear, sum(yýlSonuc.[Kaç Kere baþarýsýz gönderim iþlemi Olmuþ?]) HowManyTimesCargoFailed  from
(
select year(kargoGunleri.orderdate) [OrderYear], count(*) [Kaç Kere baþarýsýz gönderim iþlemi Olmuþ?]
from 
	(
	select o.OrderID,o.OrderDate, DATEDIFF(day,o.OrderDate, o.ShippedDate) [Kaç Günde Kargolandi?]
	from Orders o) as kargoGunleri
	where kargoGunleri.[Kaç Günde Kargolandi?] > 30
	group by kargoGunleri.OrderDate)
	as yýlSonuc
group by yýlSonuc.OrderYear
--------------------------------------------------------------------
--Deðiþken, Koþul, Döngü
--deðiþken tanýmlama
declare @durum nvarchar(6)
set @durum= 'denemfdgfdgdfge'

--select @durum Sonuc

select
case 
@durum when 'deneme' then 'EVET deneme yazýyor'
else 'HAYIR deneme Yazmýyor'
end Sonuc 

-- if kullanýmý 
declare @sayi int
Set @sayi =200
if(@sayi > 100)
begin 
select 'Bu sayý 100de  büyüktür' Sonuc
end
else
begin 
select 'Bu sayý 100den  küçüktür' Sonuc
end

--döngü while
declare @sayac int , @sonuc int
set @sayac=1 set @sonuc=1
while (@sayac < 6 )
begin
if (@sayac =1) begin break end
set @sonuc+=@sayac
set @sayac+=1
end 
print concat('Sonuç =', @sonuc)
select concat('Sonuç =', @sonuc)

--ÖRN: Ýçinde cam olan kitap var mý? EVET HAYIR

--use OduncKitapDB
--declare @kitapAdi nvarchar(50)
--set @kitapAdi='erDeNER'
--if(EXISTS(select * from Kitaplar k (nolock)
--where k.KitapAdi like '%'+@kitapAdi+'%' ))
--begin
--print 'Bu kitaptan VAR'
--end
--else
--begin
--select 'Bu kitaptan YOK!' Sonuc
--end


use OduncKitapDB
declare @kitapAdi nvarchar(50)
set @kitapAdi='er'
if(EXISTS(select * from Kitaplar k (nolock)
where k.KitapAdi like '%'+@kitapAdi+'%' ))
begin
-- kitabýn türünü istiyor
select t.TurAdi from Turler t (nolock) 
where t.Id in (select k.TurId from Kitaplar k (nolock)
where k.KitapAdi like '%'+@kitapAdi+'%' )
end
else
begin
select 'Bu kitaptan YOK!' Sonuc
end

-----------------------------------------------------------------------
-- Stored Procedure 
-- C# dilindeki metotlara karþýlýk gelir.
--Parametreli, parametresiz ve geriye deðer gönderebilir (output), geriye deðer göndermeyebilir 
--SP kýsaltmasýyla bilinirler
-- Tekrar tekrar yazýlmasý /iþlenmesi gereken iþlemleri tek bir sefer yazýp tekrar tekrar kullanýrýz.
--
--Parametre almayan bir örnek
--ÖRN: Tüm kitaplar getiren prosedür
create procedure spTumKitaplariGetir
as
begin
select * from Kitaplar (nolock)
end

--SP Nasýl Çaðrýlýr ?
execute spTumKitaplariGetir
exec spTumKitaplariGetir


--parametre alan sp
--ÖRN: Dýþardan verilen kitap adýný arayýp getiren prosedür

create procedure sp_KitapAra(@kitapAdi nvarchar(50))
as begin
select * from Kitaplar (nolock) 
where KitapAdi like '%'+@kitapAdi +'%'
end

exec sp_KitapAra 'cam'

--Var olan prosedürün içeriðini düzenliyoruz
alter procedure sp_KitapAra(@kitapAdi nvarchar(50))
as begin
declare @adet int
select @adet=count(*) from Kitaplar (nolock) 
where KitapAdi like '%'+@kitapAdi +'%'
if(@adet > 0) 
begin
select concat ('Bu kitaptan ', @adet, ' vardýr') Sonuc
end
else 
begin 
select 'Bu kitaptan YOK' Sonuc
end
end 
exec sp_KitapAra 'a'

-- ÖRN: Yeni cafe ekleyen prosedür ile ekleyelim
use CafeDB
create procedure sp_YeniCafeEkle(@trh datetime2(7), @ad nvarchar(50),@adres nvarchar(100),@tel char(13), @katSayisi tinyint)
as 
begin
insert into Cafeler (Eklenme_Tarihi, Iletisim_Telefon, Acik_Adresi,Adi,Kac_Katli) 
values (@trh,@tel,@adres,@ad,@katSayisi)
end

exec sp_YeniCafeEkle '20230323','Betül Cafe','Beþiktaþ' , null, 2

--ÖRN: Prosedür ile güncelleme yapalým
use OduncKitapDB
--ÖRN: Dýþardan idsini aldýðýmý kitabýn stok adedini 2 katýna çýkaran prosedür  
alter procedure sp_Stogu2KatinaCikar (@kitapid int)
as begin
if(exists(select * from Kitaplar (nolock) where Id=@kitapid))
begin
declare @stok int
select @stok= StokAdeti  from Kitaplar (nolock) where Id=@kitapid
update Kitaplar set StokAdeti = @stok  * 2 where Id=@kitapid
end
else
print 'Kitap YOK Stok artýþý yapýlamaz!'
end

select * from Kitaplar where Id=53 --19 stok
exec sp_Stogu2KatinaCikar 53

--Trigger -- Tetikleyici
--Çaðrýlmaksýzýn þartlar saðlandýðý sürece otomatik tetiklenen SQL sorgularýný yazdýðýmýz yapýdýr
-- Triggerlar bir rabloya baðlý olarak çalýþýr.
--Insert Update Delete iþlemlerinden SONRA ya da iþlemlerin YERÝNE yazýlýrlar
--Triggerýn 2 çeþidi vardýr:
--AFTER Trigger: Insert/Update/Delete iþlemlerinden SONRA çalýþýr.
-- INSTEAD OF : Insert/Update/Delete yerien çalýþýr. Kimin yerine çalýþýrsa o komutu diskalifiye etmiþ gibi düþünebilirsiniz.

--ÖRN: Cafeler tablosuna ekleme yapýldýðýnda tabloyu listeyen trigger
--Ekleme yapýlacak sonra listeleme (After trigger)
use CafeDB
create trigger tg_CafeListele
on Cafeler -- hangi tabloya baðlý çalýþacak?
after insert -- çeþidi (after) insert(iþlem)
as begin
select * from Cafeler
order by Id desc
end

exec sp_YeniCafeEkle '20230323','Test Cafe','Beþiktaþ' , null,2

insert into Cafeler (Eklenme_Tarihi, Iletisim_Telefon, Acik_Adresi,Adi,Kac_Katli) 
values ('20230323',null,'Beþiktaþ' ,'5031 Cafe',2)

alter trigger tg_CafeListele2
on Cafeler -- hangi tabloya baðlý çalýþacak?
after update -- çeþidi (after) insert(iþlem)
as begin
select * from Cafeler
order by Id desc
end

--ÖRN: Ödünç iþlemden sonra kitaplar tablosunda kitabýn stok adedini azaltalým. 
--after insert
use OduncKitapDB
alter trigger tg_StokAzalt
on OduncIslemler
after insert
as begin 
declare @kitapId int, @stok int
select @kitapId= KitapId from inserted
select @stok= StokAdeti  from Kitaplar (nolock) 
where Id=@kitapId
if(@stok >=1)
update Kitaplar set StokAdeti= @stok-1 where Id=@kitapId
end

select * from Kitaplar --68 stok =1  -- 46 stok= 28

insert into OduncIslemler (KayitTarihi, UyeId, KitapId, PersonelId, OduncAlinmaTarihi, OduncBitisTarihi,TeslimEttigiTarih, TeslimEttiMi)
values(getdate(),1,69,1,getdate(),dateadd(DAY,30, getdate()),null,0 )

--instead of Trigger : Komutun yerine çalýþýr

--ÖRN: Cafeler tablosundan hiç bir kayýt silinemesin

use CafeDB
alter trigger tg_Silemez
on Cafeler
instead of delete
as begin 
select 'KAYIT SÝLEMEZSÝN!'
end

delete from Cafeler where Id=5

use CafeDB
--Triggerý komut ile disable enable etme iþlemi
ALTER TABLE Cafeler DISABLE TRIGGER tg_CafeListele

ALTER TABLE Cafeler ENABLE TRIGGER tg_CafeListele

--Enable Triggers on a Table

Disable TRIGGER ALL ON Cafeler
Enable TRIGGER ALL ON Cafeler 
--Enable Triggers on a Database


ENABLE TRIGGER ALL On DATABASE  ---?

use NORTHWND

select * from Orders where ShipName='Hanari Carnes'

use CafeDB
CREATE UNIQUE INDEX idx_KategoriAdi
ON Kategoriler (Ad);

insert into Kategoriler (Ad) values ('Betül')

CREATE  INDEX idx_Calisanlar
ON Calisanlar (Ad,Soyad)


