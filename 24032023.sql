--24.03.2023 503 SQL 
--23.03.2023 perþembe günü aþaðýdaki örnekteki ufak sorunu çözdük.
--ÖRN: KitaplarYedek siimli bir tablo olmalý. Kitaplar tablosundan kayýt güncellendiðinde bir önceki halinin bilgileri KitaplarYedek kablosuna eklensin.
use OduncKitapDB
alter trigger tg_KitapYedek
on Kitaplar
instead of update
as begin
declare @kayitTarihi datetime2(7),@kitapAdi nvarchar(50),
@turId tinyint, @yazarId int, @sayfa int, @stok int,
@resimLink char(100), @silindiMi bit, @id int

select @id=Id from inserted

select @kayitTarihi=KayitTarihi, @kitapAdi=KitapAdi,
@turId=TurId, @yazarId=YazarId,@sayfa=SayfaSayisi,
@stok=StokAdeti, @resimLink=ResimLink, @silindiMi=SilindiMi
from Kitaplar (nolock) -- burayý yanlýþlýkla from inserted yazmýþýz...Burasý önceki bilgiyi alacaðýndan from Kitaplar olamlý
where Id=@id

insert into KitaplarYedek (Id,KayitTarihi,KitapAdi,TurId,
YazarId,SayfaSayisi,StokAdeti,ResimLink,SilindiMi) values 
(@id,@kayitTarihi,@kitapAdi, @turId,@yazarId, @sayfa,@stok,@resimLink,@silindiMi) 

select 
@kayitTarihi=KayitTarihi, @kitapAdi=KitapAdi,@turId=TurId, @yazarId=YazarId,@sayfa=SayfaSayisi,
@stok=StokAdeti, @resimLink=ResimLink, @silindiMi=SilindiMi,
@id=Id
from inserted

update Kitaplar set KayitTarihi=@kayitTarihi,
KitapAdi=@kitapAdi, SayfaSayisi=@sayfa, StokAdeti=@stok,
SilindiMi=@silindiMi, ResimLink=@resimLink, YazarId=@yazarId,
TurId=@turId
where Id=@id
end

select * from Kitaplar where Id=53
update Kitaplar set KitapAdi='Camda Uyuyan Kýz'where Id=53
select * from KitaplarYedek

-------------------------------------------------------------------------------
--Transaction 
IF EXISTS (SELECT * FROM sys.objects 
WHERE object_id = OBJECT_ID(N'[dbo].[503TransactionOrnek]') AND type in (N'U'))
DROP TABLE [dbo].[503TransactionOrnek]
GO
CREATE TABLE dbo.[503TransactionOrnek] (col1 INT NOT NULL)
GO

select * from [503TransactionOrnek]

insert into [503TransactionOrnek] (col1) values(100), (200),(503)

insert into [503TransactionOrnek] (col1) values(300)
insert into [503TransactionOrnek] (col1) values ('betul')

begin tran
insert into [503TransactionOrnek] (col1) values(400)
insert into [503TransactionOrnek] (col1) values ('betul')
commit

begin tran
insert into [503TransactionOrnek] (col1) values(400)
insert into [503TransactionOrnek] (col1) values (500)
rollback 


CREATE TABLE dbo.[TransactionOrnek] (
id int identity(1,1) primary key,
deger INT NOT NULL
)

select * from TransactionOrnek

insert into TransactionOrnek (deger) values(100), (200),(503)

begin tran
insert into [TransactionOrnek] (deger) values(400)
insert into [TransactionOrnek] (deger) values (500)
commit 

------------------------------------------------------------------------------
create trigger tg_KitapxeEkle
on Kitaplar 
after insert
as begin
declare @kayitTarihi datetime2(7),@kitapAdi nvarchar(50),
@turId tinyint, @yazarId int, @sayfa int, @stok int,
@resimLink char(100), @silindiMi bit, @id int

select 
@kayitTarihi=KayitTarihi, @kitapAdi=KitapAdi,@turId=TurId, @yazarId=YazarId,@sayfa=SayfaSayisi,
@stok=StokAdeti, @resimLink=ResimLink, @silindiMi=SilindiMi,
@id=Id
from inserted

insert into KitaplarX (KayitTarihi,SayfaSayisi, StokAdeti,
SilindiMi,KitapAdi, ResimLink, TurId, YazarId ) 
values (@kayitTarihi, @sayfa, @stok, @silindiMi, @kitapAdi
, @resimLink, @turId,@yazarId) 
end


insert into Kitaplar (KayitTarihi,SayfaSayisi, StokAdeti,
SilindiMi,KitapAdi, ResimLink, TurId, YazarId ) 
values  ( getdate(), 100, 100, 0 , 'Deneme SQL Mola', null, 3,3)


select @@IDENTITY
select SCOPE_IDENTITY()
select IDENT_CURRENT('KitaplarX')


select top 1 * from Kitaplar order by Id desc
select top 1 * from KitaplarX order by Id desc