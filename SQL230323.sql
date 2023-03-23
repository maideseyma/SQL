--23.03.2023 503 SQL 
-- �rn: Hangi kitap ka� kere �d�n� al�nm��
use OduncKitapDB
select k.KitapAdi , count(*) [Ka� Kere �d�n� Al�nm��t�r?]
from OduncIslemler (nolock) odnc
join Kitaplar k (nolock) on k.Id= odnc.KitapId
group by k.KitapAdi

select k.KitapAdi , count(*) [Ka� Kere �d�n� Al�nm��t�r?]
from Kitaplar k (nolock) 
join OduncIslemler odnc (nolock) on k.Id= odnc.KitapId
group by k.KitapAdi

--�RN: 1996 y�l�nda en az kazand�ran �al��an�m
use NORTHWND
select  top 1 concat(e.FirstName ,' ', e.LastName) [�al��an] , 
count(*) [Sat�� Say�s�]
from Orders o (nolock)
join Employees e (nolock) on e.EmployeeID=o.EmployeeID
where o.OrderDate >='19960101' and o.OrderDate <'19970101'
group by e.FirstName , e.LastName
order by [Sat�� Say�s�] 


--�RN: 1997 y�l�nda kazanc� min 7000 olup birim fiyat� min 20 ve i�inde ff ge�meyen �r�nlerden kazand���m
select top 10 * from [Order Details]
select p.ProductName , sum(od.UnitPrice * od.Quantity * (1- od.Discount)) [Kazan�] 
from [Order Details] od (nolock)
join Orders o (nolock) on o.OrderID=od.OrderID
join Products p (nolock) on p.ProductID=od.ProductID
where od.UnitPrice >=20 and p.ProductName not like '%ff%'
and o.OrderDate >='19970101' and o.OrderDate <'19980101'
group by p.ProductName
having sum(od.UnitPrice * od.Quantity * (1- od.Discount))  >=7000

--cast komutu
select cast(13948.6799926758 as decimal(18,0))

select p.ProductName , cast(sum(od.UnitPrice * od.Quantity * (1- od.Discount)) as decimal(18,2)) [Kazan�] 
from [Order Details] od (nolock)
join Orders o (nolock) on o.OrderID=od.OrderID
join Products p (nolock) on p.ProductID=od.ProductID
where od.UnitPrice >=20 and p.ProductName not like '%ff%'
and o.OrderDate >='19970101' and o.OrderDate <'19980101'
group by p.ProductName
having sum(od.UnitPrice * od.Quantity * (1- od.Discount))  >=7000


---SELECT SORGUSUNUN �ALI�MA SIRASI
-- 1) FROM 
-- 1,5) Varsa join join �al���r yoksa 2'ye ge�
-- 2) WHERE 
-- 3) Varsa Group by �al���r
-- 4) HAVING �al���r
-- 5) SELECT �al���r
-- 6) ORDER BY �al���r --> Alias kullan�labilir (Select'ten sonra �al��t��� i�in)

-----------------------------------------------------------------------------
--delete i�lemi DML komutu
--> hard delete  --> delete komutunu yazarak tablodan o veriyi yok etmek / silmek
--> soft delete --> Tabloya SlindiMi/ AktifMi gibi kolonlar ekleyerek bu kolonlar� g�ncellemek
use OduncKitapDB
delete from Kitaplar where Id=67 --hard delete

update Kitaplar set SilindiMi=1 where Id=53 --> (soft delete) UPDATE ��LEM�D�R

select * from Kitaplar where KitapAdi like '%cam%'

--case when then
--rownumber()
--order by
--aggregate functions
--group by having
--delete
--sub query
--de�i�ken , d�ng�
--view
--stored function
--Trigger
-- Transaction 
-------------------------------------------------------------------------------
--View: Kod ile de olu�turulur. Object Explorer penceresinden Views >> New View ile designer penceresinden de olu�turulur.

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
select   p.ProductID, p.ProductName , sum(od.UnitPrice * od.Quantity * (1- od.Discount)) [Kazan�] 
from [Order Details] od (nolock)
join Orders o (nolock) on o.OrderID=od.OrderID
join Products p (nolock) on p.ProductID=od.ProductID
where od.UnitPrice >=20 and p.ProductName not like '%ff%'
and o.OrderDate >='19970101' and o.OrderDate <'19980101'
group by p.ProductName, p.ProductID


use OduncKitapDB 
select * from KitapTurYazarView

-------------------------------------------------------------
--sub query: Alt sorgu anlam�na gelir. ��-i�e select sorgusu  yazmakt�r.
--�RN: Shipper Speedy Express isimli kargoyla verilen sipari�ler
use NORTHWND
select * from Orders o (nolock)
where o.ShipVia =
(select ShipperID from Shippers where CompanyName='Speedy Express')

-- Derived T�retilmi� tablo :
--Parantez i�ine al�nan Altsorguya TAKMA �S�M (alias) verilerek
--t�retilmi� tablo haline getirip kullanabilirsiniz.
--�RN: Kargoda 30 g�n� a�an sipari�ler 

select * from
(
select o.OrderID, o.OrderDate, o.ShippedDate,
DATEDIFF(day, o.OrderDate, o.ShippedDate) [Ka� G�nde Kargolandi?]
from Orders (nolock) o ) kargoGunleri
where [Ka� G�nde Kargolandi?] >35

--�RN ***** 35 g�n� a�an kargoya verme i�lemi problem olu�turmakatad�r. (ba�ar�s�z g�nderim i�lemi say�lmaktad�r) Firman�n y�l baz�nda ka� defa ba�ar�s�z g�nderim i�lemi olmu�tur?

select year(kargoGunleri.OrderDate) Y�l , count(*) [Ka� Kere ba�ar�s�z g�nderim i�lemi Olmu�?]
from 
(select o.OrderID, o.OrderDate, o.ShippedDate,
DATEDIFF(day, o.OrderDate, o.ShippedDate) [Ka� G�nde Kargolandi?]
from Orders (nolock) o 
where DATEDIFF(day, o.OrderDate, o.ShippedDate) > 35) kargoGunleri 
group by year(kargoGunleri.OrderDate)

-------------------------------------------------------------------
select y�lSonuc.OrderYear, sum(y�lSonuc.[Ka� Kere ba�ar�s�z g�nderim i�lemi Olmu�?]) HowManyTimesCargoFailed  from
(
select year(kargoGunleri.orderdate) [OrderYear], count(*) [Ka� Kere ba�ar�s�z g�nderim i�lemi Olmu�?]
from 
	(
	select o.OrderID,o.OrderDate, DATEDIFF(day,o.OrderDate, o.ShippedDate) [Ka� G�nde Kargolandi?]
	from Orders o) as kargoGunleri
	where kargoGunleri.[Ka� G�nde Kargolandi?] > 30
	group by kargoGunleri.OrderDate)
	as y�lSonuc
group by y�lSonuc.OrderYear
--------------------------------------------------------------------
--De�i�ken, Ko�ul, D�ng�
--de�i�ken tan�mlama
declare @durum nvarchar(6)
set @durum= 'denemfdgfdgdfge'

--select @durum Sonuc

select
case 
@durum when 'deneme' then 'EVET deneme yaz�yor'
else 'HAYIR deneme Yazm�yor'
end Sonuc 

-- if kullan�m� 
declare @sayi int
Set @sayi =200
if(@sayi > 100)
begin 
select 'Bu say� 100de  b�y�kt�r' Sonuc
end
else
begin 
select 'Bu say� 100den  k���kt�r' Sonuc
end

--d�ng� while
declare @sayac int , @sonuc int
set @sayac=1 set @sonuc=1
while (@sayac < 6 )
begin
if (@sayac =1) begin break end
set @sonuc+=@sayac
set @sayac+=1
end 
print concat('Sonu� =', @sonuc)
select concat('Sonu� =', @sonuc)

--�RN: ��inde cam olan kitap var m�? EVET HAYIR

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
-- kitab�n t�r�n� istiyor
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
-- C# dilindeki metotlara kar��l�k gelir.
--Parametreli, parametresiz ve geriye de�er g�nderebilir (output), geriye de�er g�ndermeyebilir 
--SP k�saltmas�yla bilinirler
-- Tekrar tekrar yaz�lmas� /i�lenmesi gereken i�lemleri tek bir sefer yaz�p tekrar tekrar kullan�r�z.
--
--Parametre almayan bir �rnek
--�RN: T�m kitaplar getiren prosed�r
create procedure spTumKitaplariGetir
as
begin
select * from Kitaplar (nolock)
end

--SP Nas�l �a�r�l�r ?
execute spTumKitaplariGetir
exec spTumKitaplariGetir


--parametre alan sp
--�RN: D��ardan verilen kitap ad�n� aray�p getiren prosed�r

create procedure sp_KitapAra(@kitapAdi nvarchar(50))
as begin
select * from Kitaplar (nolock) 
where KitapAdi like '%'+@kitapAdi +'%'
end

exec sp_KitapAra 'cam'

--Var olan prosed�r�n i�eri�ini d�zenliyoruz
alter procedure sp_KitapAra(@kitapAdi nvarchar(50))
as begin
declare @adet int
select @adet=count(*) from Kitaplar (nolock) 
where KitapAdi like '%'+@kitapAdi +'%'
if(@adet > 0) 
begin
select concat ('Bu kitaptan ', @adet, ' vard�r') Sonuc
end
else 
begin 
select 'Bu kitaptan YOK' Sonuc
end
end 
exec sp_KitapAra 'a'

-- �RN: Yeni cafe ekleyen prosed�r ile ekleyelim
use CafeDB
create procedure sp_YeniCafeEkle(@trh datetime2(7), @ad nvarchar(50),@adres nvarchar(100),@tel char(13), @katSayisi tinyint)
as 
begin
insert into Cafeler (Eklenme_Tarihi, Iletisim_Telefon, Acik_Adresi,Adi,Kac_Katli) 
values (@trh,@tel,@adres,@ad,@katSayisi)
end

exec sp_YeniCafeEkle '20230323','Bet�l Cafe','Be�ikta�' , null, 2

--�RN: Prosed�r ile g�ncelleme yapal�m
use OduncKitapDB
--�RN: D��ardan idsini ald���m� kitab�n stok adedini 2 kat�na ��karan prosed�r  
alter procedure sp_Stogu2KatinaCikar (@kitapid int)
as begin
if(exists(select * from Kitaplar (nolock) where Id=@kitapid))
begin
declare @stok int
select @stok= StokAdeti  from Kitaplar (nolock) where Id=@kitapid
update Kitaplar set StokAdeti = @stok  * 2 where Id=@kitapid
end
else
print 'Kitap YOK Stok art��� yap�lamaz!'
end

select * from Kitaplar where Id=53 --19 stok
exec sp_Stogu2KatinaCikar 53

--Trigger -- Tetikleyici
--�a�r�lmaks�z�n �artlar sa�land��� s�rece otomatik tetiklenen SQL sorgular�n� yazd���m�z yap�d�r
-- Triggerlar bir rabloya ba�l� olarak �al���r.
--Insert Update Delete i�lemlerinden SONRA ya da i�lemlerin YER�NE yaz�l�rlar
--Trigger�n 2 �e�idi vard�r:
--AFTER Trigger: Insert/Update/Delete i�lemlerinden SONRA �al���r.
-- INSTEAD OF : Insert/Update/Delete yerien �al���r. Kimin yerine �al���rsa o komutu diskalifiye etmi� gibi d���nebilirsiniz.

--�RN: Cafeler tablosuna ekleme yap�ld���nda tabloyu listeyen trigger
--Ekleme yap�lacak sonra listeleme (After trigger)
use CafeDB
create trigger tg_CafeListele
on Cafeler -- hangi tabloya ba�l� �al��acak?
after insert -- �e�idi (after) insert(i�lem)
as begin
select * from Cafeler
order by Id desc
end

exec sp_YeniCafeEkle '20230323','Test Cafe','Be�ikta�' , null,2

insert into Cafeler (Eklenme_Tarihi, Iletisim_Telefon, Acik_Adresi,Adi,Kac_Katli) 
values ('20230323',null,'Be�ikta�' ,'5031 Cafe',2)

alter trigger tg_CafeListele2
on Cafeler -- hangi tabloya ba�l� �al��acak?
after update -- �e�idi (after) insert(i�lem)
as begin
select * from Cafeler
order by Id desc
end

--�RN: �d�n� i�lemden sonra kitaplar tablosunda kitab�n stok adedini azaltal�m. 
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

--instead of Trigger : Komutun yerine �al���r

--�RN: Cafeler tablosundan hi� bir kay�t silinemesin

use CafeDB
alter trigger tg_Silemez
on Cafeler
instead of delete
as begin 
select 'KAYIT S�LEMEZS�N!'
end

delete from Cafeler where Id=5

use CafeDB
--Trigger� komut ile disable enable etme i�lemi
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

insert into Kategoriler (Ad) values ('Bet�l')

CREATE  INDEX idx_Calisanlar
ON Calisanlar (Ad,Soyad)


