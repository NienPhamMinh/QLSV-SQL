select*into HOADON1
from HOADON
select * into CTHD1
from CTHD

/*Ngôn ngữ định nghĩa dữ liệu (Data Definition Language)
1.Thêm vào thuộc tính GHICHU có kiểu dữ liệu varchar(20) cho quan hệ SANPHAM.*/
alter table sanpham1 add GHICHU  varchar (20)
/* 2.Thêm vào thuộc tính LOAIKH có kiểu dữ liệu là tinyint cho quan hệ KHACHHANG */
alter table khachhang1 alter column loaikh tinyint
/* 3. Sửa kiểu dữ liệu của thuộc tính GHICHU trong quan hệ SANPHAM thành varchar(100) */
alter table sanpham1 alter column ghichu varchar (100) 
/* 4. Xóa thuộc tính GHICHU trong quan hệ SANPHAM */
alter table sanpham1 drop column ghichu
/* 5. Làm thế nào để thuộc tính LOAIKH trong quan hệ KHACHHANG có thể lưu các giá trị là: “Vang lai”, “Thuong xuyen”, “Vip”, … */
alter table khachhang1 alter column loaikh varchar (100) 
/* 6.Đơn vị tính của sản phẩm chỉ có thể là (“cay”,”hop”,”cai”,”quyen”,”chuc”) */
alter table sanpham1 add constraint ck_dvt check (dvt like 'cay'or dvt like 'hop'or dvt like 'cai'or dvt like 'quyen'or dvt like'chuc')
/*7. Giá bán của sản phẩm từ 500 đồng trở lên.*/
alter table sanpham1 add constraint sp1_gia check (gia>500)
/*8. Mỗi lần mua hàng, khách hàng phải mua ít nhất 1 sản phẩm.*/
alter table cthd1 add constraint check_sl check (SL>=1)
/*9.  Ngày khách hàng đăng ký là khách hàng thành viên phải lớn hơn ngày sinh của người đó. */
alter table khachhang1 add constraint kh1_ndk check (ngdk >= ngsinh)
/* Ngôn ngữ thao tác dữ liệu */
/* 2.	Tạo quan hệ SANPHAM1 chứa toàn bộ dữ liệu của quan hệ SANPHAM. Tạo quan hệ KHACHHANG1 chứa toàn bộ dữ liệu của quan hệ KHACHHANG.*/
select * into sanpham1 from SANPHAM
select * into khachhang2 from KHACHHANG1
/* 3. Cập nhật giá tăng 5% đối với những sản phẩm do “Thai Lan” sản xuất (cho quan hệ SANPHAM1)*/
select * from SANPHAM1
update SANPHAM1 
set GIA =GIA + GIA*0.05
where NUOCSX ='thai lan'
select * from SANPHAM1
/* 4. Cập nhật giá giảm 5% đối với những sản phẩm do “Trung Quoc” sản xuất có giá từ 10.000 trở xuống (cho quan hệ SANPHAM1).*/
update SANPHAM1
set gia = gia - gia*0.05
where NUOCSX = 'trung quoc' and gia > 10000
/* 5.	Cập nhật giá trị LOAIKH là “Vip” đối với những khách hàng đăng ký thành viên trước ngày 1/1/2007 có doanh số từ 10.000.000 trở lên hoặc khách hàng đăng ký thành viên từ 1/1/2007 trở về sau có doanh số từ 2.000.000 trở lên (cho quan hệ KHACHHANG1).*/
set dateformat dmy
select * from KHACHHANG1
update KHACHHANG1
set LOAIKH = 'Vip'
where (NGDK < '1/1/2007' and doanhso >= 10000000 )or (NGDK >= '1/1/2007' and doanhso >= 2000000)
select * from KHACHHANG1
/*III. ngôn ngữ truy vấn dữ liệu có  cấu trúc 
cau 1: In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất.*/
select MASP,TENSP
from SANPHAM1
where NUOCSX = 'trung quoc'
/* cau 2:In ra danh sách các sản phẩm (MASP, TENSP) có đơn vị tính là “cay”, ”quyen”. */
select masp, tensp
from SANPHAM1
where DVT = 'cay'or DVT= 'quyen'
/* 3. In ra danh sách các sản phẩm (MASP,TENSP) có mã sản phẩm bắt đầu là “B” và kết thúc là “01”.*/
select * from SANPHAM1
select masp, tensp
from SANPHAM1 
where masp like 'B%01'
/*4.  In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quốc” sản xuất có giá từ 30.000 đến 40.000.*/
select masp, tensp
from SANPHAM1 
where NUOCSX = 'trung quoc' and GIA between 30000 and 40000
/*5. In ra danh sách các sản phẩm (MASP,TENSP)
do “Trung Quoc” hoặc “Thai Lan” sản xuất có giá từ 30.000 đến 40.000.*/
select masp, tensp
from SANPHAM1 
where (NUOCSX = 'trung quoc' or NUOCSX = 'thailan')and (GIA between 30000 and 40000)
 /*6.    In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 1/1/2007 và ngày 2/1/2007.*/
 select sohd, trigia
 from HOADON
 where NGHD between '1/1/2007' and '02/01/2007'
/* 7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 1/2007,
sắp xếp theo ngày (tăng dần) và trị giá của hóa đơn (giảm dần).*/
select sohd, trigia from HOADON1 where MONTH (nghd)=1 and YEAR (nghd)= 2007
order by NGHD asc, TRIGIA desc
/*8.In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 1/1/2007.*/
 select kh1.MAKH, hoten
 from KHACHHANG1 kh1, HOADON1 hd1
 where kh1.MAKH = hd1.MAKH and hd1.NGHD= '01/01/2007'
/*9.In ra số hóa đơn, trị giá các hóa đơn do nhân viên có tên “Nguyen Van B”
lập trong ngày 28/10/2006.*/
select * from nhanvien1
select * from HOADON1
select sohd, trigia
from nhanvien1 nv1, HOADON1 hd1
where nv1.manv = hd1.MANV and nv1.hoten ='nguyen van b' and hd1.NGHD = '28/10/2006'
/* 10.In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên “Nguyen Van A” mua trong tháng 10/2006.*/
select sp1.TENSP, sp1.MASP
from sanpham1 sp1,KHACHHANG1 kh1,HOADON1 hd1,CTHD1
where sp1.MASP= CTHD1.MASP
and hd1.SOHD=CTHD1.SOHD
and hd1.MAKH = kh1.MAKH
and kh1.HOTEN = 'nguyen van a'
and MONTH ( hd1.NGHD)= 10 and YEAR ( hd1.NGHD)= 2006
--11 Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”.
select distinct SOHD , sl from CTHD where MASP = 'bb01' or MASP ='bb02'
--12.	Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
select  SOHD,SL,MASP from CTHD where (MASP = 'bb01' or MASP ='bb02') and ( SL between 10 and 20)
--13.	Tìm các	số hóa đơn mua cùng lúc 2 sản phẩm có mã số “BB01” và “BB02”, mỗi sản phẩm mua với số lượng từ 10 đến 20.
select sohd from CTHD where MASP = 'bb01' and SL between 10 and 20
intersect 
(
	select sohd from CTHD where MASP ='bb02' and sl between 10 and 20 )
--14 In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất hoặc các sản phẩm được bán ra trong ngày 1/1/2007
select  distinct sp.masp, sp.tensp from SANPHAM sp , HOADON hd , CTHD
where cthd.SOHD = hd.SOHD 
and CTHD.MASP=sp.MASP
and (sp.NUOCSX = 'trung quoc' or hd.NGHD='01/01/2007')
--15.	In ra danh sách các sản phẩm (MASP,TENSP) không bán được.
select  distinct sp.masp, sp.tensp 
from SANPHAM sp 
where sp.MASP not in ( select MASP from CTHD)
--16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006
select sp.masp, sp.tensp 
from SANPHAM sp 
where sp.MASP not in ( select MASP from CTHD, HOADON hd where year (hd.NGHD)=2006 and hd.SOHD =cthd.SOHD)
--17. In ra danh sách các sản phẩm (MASP,TENSP) do “Trung Quoc” sản xuất không bán được trong năm 2006.
select sp.masp, sp.tensp 
from SANPHAM sp 
where sp.MASP not in ( select MASP from CTHD, HOADON hd  where year (hd.NGHD)=2006 and hd.SOHD =cthd.SOHD )and sp.NUOCSX='trung quoc'
--18 .Tìm số hóa đơn đã mua tất cả các sản phẩm do Singapore sản xuất
select distinct hd.SOHD
from HOADON hd, CTHD, SANPHAM sp
where CTHD.SOHD=hd.SOHD
and exists ( select sp.masp
from SANPHAM sp 
where sp.NUOCSX ='singapore' and sp.MASP=CTHD.MASP)
--19.  Tìm số hóa đơn trong năm 2006 đã mua ít nhất tất cả các sản phẩm do Singapore sản xuất
select distinct hd.SOHD
from HOADON hd, CTHD, SANPHAM sp
where CTHD.SOHD=hd.SOHD and YEAR ( hd.NGHD) =2006
and exists ( select sp.masp
from SANPHAM sp 
where sp.NUOCSX ='singapore' and sp.MASP=CTHD.MASP) 
select * from CTHD
select * from HOADON
--20.  Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?
select count (*) as[ Số hóa đơn không phải của khách hàng thành viên mua]
from HOADON  
where MAKH is null
--21. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006
select count ( distinct cthd.MASP) as [ SẢN PHẨM KHÁC NHAU ĐƯỢC BÁN RA TRONG NĂM 2006]
from  CTHD, HOADON
where CTHD.SOHD = HOADON.SOHD
and year ( HOADON.NGHD) = 2006
--22. cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu ?
SELECT MAX( HD.TRIGIA) AS [ Hóa đơn cao nhất ], MIN (hd.trigia) as [Hóa đơn thấp nhất]
FROM HOADON HD
--23.  Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu
select round (avg (trigia),2) as [ Giá trung bình ]
from HOADON hd
--24.  Tính doanh thu bán hàng trong năm 2006
select sum (trigia) as [ Doanh thu 2006]
from HOADON 
where YEAR (nghd) = 2006
--25. Tìm số hóa đơn có trị giá cao nhất trong năm 2006
select max (trigia) as [ Doanh thu cao nhat 2006] 
from HOADON 
where YEAR (nghd) = 2006
--26. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006
select distinct kh.HOTEN,  hd.TRIGIA as [ hóa đơn có giá trị cao nhất]
from HOADON hd, KHACHHANG kh
where hd.MAKH = kh.MAKH 
and year (NGHD) =2006
and hd.TRIGIA = ( select max( hd.TRIGIA) from HOADON hd where YEAR (hd.NGHD) = 2006)
--27. In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất
select top 3 doanhso as [KH có doanh số cao nhất], MAKH,HOTEN
from KHACHHANG
order by doanhso DESC
--28 In ra danh sách các sản phẩm (MASP, TENSP) 3 sản phẩm có giá bán mức giá cao nhất
select top 3 masp, tensp,gia
from SANPHAM
order by GIA desc
--29. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm)
select top 3 masp, tensp,gia
from SANPHAM
where NUOCSX = 'thai lan'
order by GIA desc
select * from SANPHAM
--30 In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất
select top 3 masp, tensp,gia
from SANPHAM
where NUOCSX = 'trung quoc'
order by GIA desc 
-- 31. In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng)
select top 3 *
from KHACHHANG
order by doanhso desc
-- 32 Tính tổng số sản phẩm do “Trung Quoc” sản xuất
select count(masp) as [ tổng số sản phẩm do Trung Quoc]
from SANPHAM
where NUOCSX = 'trung quoc'
-- 33.Tính tổng số sản phẩm của từng nước sản xuất
select nuocsx, count(masp) as [ tổng số sản phẩm do Trung Quoc]
from SANPHAM
group by NUOCSX
--34.  Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm
select nuocsx, max(gia) as [Giá bán cao nhất], min(gia) as [Giá bán thấp nhất], ROUND(avg(gia),2) as [Giá trung bình]
from SANPHAM
group by NUOCSX
--35. Tính doanh thu bán hàng mỗi ngày
select nghd as [Ngày tháng năm],sum (TRIGIA) as[ Doanh thu] 
from HOADON 
group by NGHD 
order by nghd desc
--36.Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006
select * from CTHD
select distinct cthd.MASP ,sum (cthd.sl) tổngsốlượng , sp.TENSP
from HOADON hd, CTHD ,SANPHAM sp
where hd.SOHD = CTHD.SOHD and sp.MASP = CTHD.MASP and month ( hd.nghd) = 10 and YEAR ( hd.NGHD)=2006
group by  cthd.MASP, sp.TENSP
order by tổngsốlượng asc
--37. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.
select CTHD.SOHD, COUNT ( distinct cthd.masp) as Sốsảnphẩm
from CTHD, HOADON HD
WHERE CTHD.SOHD = hd.SOHD
GROUP BY CTHD.SOHD
having COUNT ( distinct cthd.masp)  >=4
--38 Tính doanh thu bán hàng của từng tháng trong năm 2006
select sum(trigia) Doanhthu, MONTH (NGHD) Tháng from HOADON where YEAR ( NGHD)= 2006 group by MONTH( NGHD)
--39. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau).
select hd.SOHD 
from HOADON hd, CTHD, SANPHAM sp
where cthd.SOHD = hd.SOHD 
and sp.MASP= CTHD.MASP
and sp.NUOCSX = 'viet nam'
group by hd.SOHD
having count (distinct cthd.masp) >=3
--40. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.
 
select kh.MAKH, kh.HOTEN,count ( hd.MAKH)  solanmua
from HOADON hd, KHACHHANG kh
where hd.MAKH = kh.MAKH
group by kh.MAKH, kh.HOTEN
--41. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất
select  MONTH ( hd.NGHD) as [ Tháng trong năm 2006], sum ( hd.trigia) as [ Doanh thu theo tháng]
from HOADON hd
where year ( hd.NGHD)=2006
group by  MONTH ( hd.NGHD)
order by sum ( hd.trigia) desc
--42. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006
select distinct CTHD.MASP, sum ( cthd.sl) as [ tổng số lượng ], sp.TENSP
from SANPHAM sp, CTHD ,HOADON hd
where  year ( hd.NGHD)=2006
and hd.SOHD =CTHD.SOHD
and sp.MASP= CTHD.MASP
group by CTHD.MASP,sp.TENSP
order by sum ( cthd.sl) asc
--43. Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất
select sp1.MASP, sp1.NUOCSX , sp1.TENSP
from SANPHAM sp1
where exists ( select  sp2.NUOCSX
from SANPHAM sp2
group by sp2.NUOCSX 
having sp2.NUOCSX = sp1 .NUOCSX
and sp1.GIA = MAX ( sp2.GIA)
)
--44. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau
select sp1.NUOCSX
from SANPHAM sp1
group by sp1.NUOCSX
having count ( distinct gia) >=3
--45. Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất
select * 
from KHACHHANG 
where MAKH in 
(
	select top 1 with ties hd.MAKH
	from ( 
	select top 10 kh2.makh from KHACHHANG kh2 order by kh2.doanhso desc ) as A 
	join HOADON hd on hd.MAKH = A.MAKH
	group by hd.MAKH 
	order by count (*) desc )

