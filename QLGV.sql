USE QLGV_22210068
SELECT * FROM HOCVIEN
/* tạo khóa ngoại 
create table HOCVIEN
( 
	mahv char (5),
	ho varchar (40),
	ten varchar (40),
	ngsinh smalldatetime,
	gioitinh varchar (3),
	noisinh varchar (40),
	malop varchar (6),
	constraint PK_HOCVIEN primary key (mahv)
)
create table dieukien
(
	mamh varchar (10),
	mamh_truoc varchar (10)
	constraint pk_dieukien primary key (mamh, mamh_truoc)
)
create table giangday 
(
	malop varchar (5),
	mamh varchar (5),
	constraint pk_giangday primary key (malop, mamh)
)
create table ketquathi (
	mahv varchar (5),
	mamh varchar (5),
	lanthi int ,
	constraint pk_ketquathi primary key (mahv,mamh,lanthi)
)
insert into HOCVIEN values ('hv001', 'Pham', 'Minh Nien', '28/08/1997','nam', 'Ho chi minh',k0011)
alter table lop add constraint fk_trglop foreign key (trglop) references HOCVIEN (MAHV)
alter table lop add constraint fk_magvcn foreign key (magvcn) references giaovien (magv)
alter table hocvien add constraint fk_malop foreign key (malop) references lop (malop)
alter table khoa add constraint fk_trgkhoa foreign key (trgkhoa) references giaovien (magv)
alter table monhoc add constraint fk_makhoa foreign key (makhoa) references khoa (makhoa)
alter table giaovien add constraint fk_makhoa foreign key (makhoa) references khoa (makhoa)
alter table dieukien add constraint fk_mamh foreign key (mamh) references monhoc (mamh)
alter table dieukien add constraint fk_mamh_truoc foreign key (mamh_truoc) references (mamh_truoc)
alter table ketquathi add constraint fk_mahv foreign key (mahv) references hocvien (mahv)
*/
--2.	Mã học viên là một chuỗi 5 ký tự, 3 ký tự đầu là mã lớp, 2 ký tự cuối cùng là số thứ tự học viên trong lớp. VD: “K1101”
-- tạo procedure 
create procedure danh_sach_hocvien
as select* from HOCVIEN
exec danh_sach_hocvien
create procedure danh_sach_giaovien
as select* from GIAOVIEN
create procedure danh_sach_giangday
as select* from GIANGDAY
create procedure danh_sach_ketquathi
as select* from KETQUATHI
create procedure danh_sach_khoa
as select* from khoa
create procedure danh_sach_lop
as select * from LOP
create procedure Tim_Hocvien @mahv char (10)
as select * from HOCVIEN where MAHV = @mahv
exec danh_sach_hocvien
exec Tim_Hocvien 'k1103'
exec danh_sach_giaovien
create procedure Tim_Giaovien @magv char (10),  @hocvi varchar (40)
as 
	select * from GIAOVIEN where MAGV = @magv  and  HOCVI = @hocvi
exec Tim_Giaovien'gv02','ts'
exec danh_sach_ketquathi
create procedure Tim_Diem @mahv char (10), @diem numeric(4,2) output
as select @diem = diem from KETQUATHI where MAHV = @mahv
declare @diemhv_1103 numeric (4,2)
exec Tim_Diem 'k1103', @diemhv_1103 output
print @diemhv_1103
  create trigger Them_xoa_mahv
 on hocvien
 for insert, update
 as 
	begin 
	declare @siso int, @mahv varchar (5), @malop varchar (3)
	select @mahv = mahv, @malop = malop from inserted
	select @siso = siso from LOP where LOP.MALOP = @malop
	
	if left (@mahv,3)<>@malop
	begin 
		print (' 3 Ky tu dau phai la ma lop')
		rollback transaction 
		end
	else if cast(right (@mahv,2)as int) not between 1 and @siso -- cast ( kieu du lieu cu AS kieu du lieu moi )
	begin
		print (' 2 so cuoi cua mahv phai la so thu tu trong lop ')
		rollback transaction 
	end
end
drop trigger them_xoa_mahv-- xóa trigger	
alter table hocvien
disable trigger them_xoa_mahv -- vô hiệu trigger trên 1 bảng
alter table hocvien
enable trigger them_xoa_mahv -- đóng vô hiệu hóa trigger
--3.	Thuộc tính GIOITINH chỉ có giá trị là “Nam” hoặc “Nu”.
alter table hocvien add constraint check_gt check (gioitinh in ('nam','nu')) 
--4.	Điểm số của một lần thi có giá trị từ 0 đến 10 và cần lưu đến 2 số lẽ (VD: 6.22)
alter table ketquathi add constraint check_ketquathi check 
( diem between 0 and 11.99)
--5. Kết quả thi là “Dat” nếu điểm từ 5 đến 10  và “Khong dat” nếu điểm nhỏ hơn 5
exec danh_sach_ketquathi
alter table ketquathi add constraint check_kqt check
( ( ketqua ='dat' and diem between 5.00 and 10.00) or ( ketqua='khong dat' and diem <5))
--6. Học viên thi một môn tối đa 3 lần
alter table ketquathi add constraint check_lanthi check (lanthi <=3)
--7. Học kỳ chỉ có giá trị từ 1 đến 3
alter table giangday add constraint check_hocky check (hocky between 1 and 3)
--8. Học vị của giáo viên chỉ có thể là “CN”, “KS”, “Ths”, ”TS”, ”PTS”
alter table giaovien add constraint check_hocvi check (hocvi in ('CN','KS','Ths','TS','PTS'))
--9. Lớp trưởng của một lớp phải là học viên của lớp đó
create trigger ins_hocvien_loptruong on lop
for insert , update 
as 
	begin
	if not exists ( select * from inserted i, HOCVIEN hv where i.TRGLOP = hv.MAHV and i.MALOP=hv.MALOP)
		begin 
			print 'Lỗi: Lớp trưởng của 1 lớp phải là học viên của lớp đó'
			rollback transaction 
		end
	end
--10. Học viên ít nhất là 18 tuổi
alter table hocvien add constraint check_ngsinh check ( (year(getdate()) - year (ngsinh))>=18)
--11. Giảng dạy một môn học ngày bắt đầu (TUNGAY) phải nhỏ hơn ngày kết thúc (DENNGAY).
alter table giangday add constraint check_ngaygiangday check (tungay < denngay)
--12. Giáo viên khi vào làm ít nhất là 22 tuổi.
alter table giaovien add constraint check_tuoigiaovien check ((year (getdate())-year (ngsinh))>=22)
--13. Tất cả các môn học đều có số tín chỉ lý thuyết và tín chỉ thực hành chênh lệch nhau không quá 3.
alter table monhoc add constraint check_tinchi check ( abs (tclt - tcth) <=3)
--14.	Mỗi học kỳ của một năm học, một lớp chỉ được học tối đa 3 môn.
exec danh_sach_giangday
create trigger ins_themMH on giangday 
for insert , update 
as 
	begin 
	declare @malop_new char (10), @mamh_new char (10), @hocky_new tinyint
	select @malop_new = malop, @mamh_new = mamh, @hocky_new = hocky from inserted
		if( (select count ( distinct mamh )from GIANGDAY where @malop_new =MALOP and @hocky_new = HOCKY) >3)
		begin
			print ( ' 1 lớp 1 học kỳ chỉ học tối đa 3 môn')
			rollback transaction 
		end
	end
--15. Sỉ số của một lớp bằng với số lượng học viên thuộc lớp đó.
create trigger ins_syso on lop
for insert,update, delete
as
	begin 
	declare @siso tinyint, @malop char (10)
	select @siso = siso , @malop = malop from inserted
	if @siso <>  ( select count (mahv) from HOCVIEN where malop=@malop)
	begin 
		print (' Sĩ số của 1 lớp phải bằng số lượng học viên của lớp đó ')
		rollback transaction
	end
end
-- 19.	Các giáo viên có cùng học vị, học hàm, hệ số lương thì mức lương bằng nhau.
create trigger ins_mucluong on giaovien
for insert,update, delete
as
	begin 
	declare @mucluong money, @hocvi varchar(40), @hocham varchar (40)
	select @mucluong = MUCLUONG , @hocvi = HOCVI , @hocham = hocham from inserted
	select hocvi, hocham from GIAOVIEN 
	if @mucluong <> ( select MUCLUONG from GIAOVIEN  where  hocvi= @hocvi  and hocham = @hocham )
	begin 
		print ('Giáo viên có cùng học vị và học hàm thì mức lương bằng nhau ')
		rollback transaction
	end
end
--20. Học viên chỉ được thi lại (lần thi >1) khi điểm của lần thi trước đó dưới 5.
--21.  Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).
create trigger ins_ngaythi on ketquathi
for insert,update, delete
as
	begin 
	declare @mahv char (10), @mamh char(10), @ngthi smalldatetime
	select @mahv = MAHV , @mamh = MAMH , @ngthi = NGTHI from inserted
	if @ngthi > ( select ngthi from KETQUATHI kq where kq.MAHV=@mahv and kq.MAMH =@mamh )
	begin 
		print ('Ngày thi của lần thi sau phải lớn hơn ngày thi của lần thi trước (cùng học viên, cùng môn học).')
		rollback transaction
	end
end
--23. Học viên chỉ được thi những môn mà lớp của học viên đó đã học xong.
--II
-- 1.	Tăng hệ số lương thêm 0.2 cho những giáo viên là trưởng khoa
exec danh_sach_giaovien
exec danh_sach_khoa
select * from GIAOVIEN1
update GIAOVIEN1
set HESO = heso+HESO*0.2
where MAGV in (
select KHOA1.TRGKHOA
from KHOA1 )
/*2. 2.	Cập nhật giá trị điểm trung bình tất cả các môn học  (DIEMTB) 
của mỗi học viên (tất cả các môn học đều có hệ số 1 và nếu học viên thi một môn nhiều lần, 
chỉ lấy điểm của lần thi sau cùng).*/
alter table hocvien1 add  DiemTB numeric (4,2)
select * from HOCVIEN1

UPDATE HOCVIEN1
SET DiemTB =
(
	SELECT AVG(Diem)
	FROM KetQuaThi
	WHERE LanThi = (SELECT MAX(LanThi) FROM KetQuaThi KQ WHERE MaHV = KetQuaThi.MaHV GROUP BY MaHV)
	GROUP BY MaHV
	HAVING MaHV = HOCVIEN1.MaHV
)
--3. Cập nhật giá trị cho cột GHICHU là “Cam thi” đối với trường hợp: học viên có một môn bất kỳ thi lần thứ 3 dưới 5 điểm
alter table hocvien1 add  GHICHU VARCHAR (40)
UPDATE HOCVIEN1
SET GHICHU = 'Cam thi'
WHERE MAHV IN 
(
	SELECT MAHV
	FROM KETQUATHI
	WHERE LANTHI = 3 AND DIEM < 5
)
SELECT * FROM HOCVIEN1
--4. Cập nhật giá trị cho cột XEPLOAI trong quan hệ HOCVIEN như sau: 
-- Nếu DIEMTB >= 9 thì XEPLOAI = ”XS”
-- Nếu 8 <= DIEMTB < 9 thì XEPLOAI = “G”
-- Nếu 6.5 <= DIEMTB < 8 thì XEPLOAI = “K”
-- Nếu 5 <= DIEMTB < 6.5 thì XEPLOAI = “TB” 
-- Nếu DIEMTB < 5 thì XEPLOAI = ”Y” 
alter table hocvien1 add  XEPLOAI VARCHAR (40)
update HOCVIEN1
set xeploai = 
( case
	WHEN DIEMTB >= 9 THEN 'XS'
	WHEN DIEMTB >= 8 AND DIEMTB < 9 THEN 'G'
	WHEN DIEMTB >= 6.5 AND DIEMTB < 8 THEN 'K'
	WHEN DIEMTB >= 5 AND DIEMTB < 6.5 THEN 'TB'
	WHEN DIEMTB < 5 THEN 'Y'
	END
)
--III.
--1. 	In ra danh sách (mã học viên, họ tên, ngày sinh, mã lớp) lớp trưởng của các lớp.
SELECT  MAHV,HO,TEN,NGSINH,HOCVIEN.MALOP
FROM HOCVIEN, LOP 
WHERE LOP.TRGLOP = MAHV
--2In ra bảng điểm khi thi (mã học viên, họ tên , lần thi, điểm số) môn CTRR của lớp “K12”, sắp xếp theo tên, họ học viên.
SELECT  hv.MAHV , (HO+' '+TEN) [Họ và tên], kq.LANTHI, kq.DIEM
from HOCVIEN hv, KETQUATHI kq 
where  hv.MAHV=kq.MAHV and MAMH ='ctrr' and MALOP = 'k12'  
order by [Họ và tên] asc
--3. In ra danh sách những học viên (mã học viên, họ tên) và những môn học mà học viên đó thi lần thứ nhất đã đạt
SELECT  hv.MAHV , (HO+' '+TEN) [Họ và tên], mh.TENMH
from HOCVIEN hv, monhoc mh, ketquathi kq
where hv.MAHV = kq.MAHV 
and	kq.MAMH = mh.MAMH
and kq.LANTHI = 1 
and kq.KETQUA ='dat'
--4. n ra danh sách học viên (mã học viên, họ tên) của lớp “K11” thi môn CTRR không đạt (ở lần thi 1)
SELECT  hv.MAHV , (HO+' '+TEN) [Họ và tên], mh.TENMH,hv.MALOP
from HOCVIEN hv, monhoc mh, ketquathi kq
where hv.MAHV = kq.MAHV 
and	kq.MAMH = mh.MAMH
and MALOP = 'k11'
and kq.MAMH ='ctrr'
and kq.LANTHI =1
and kq.KETQUA ='khong dat'
--5.   Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả các lần thi)
SELECT  distinct hv.MAHV , (HO+' '+TEN) [Họ và tên], mh.TENMH,hv.MALOP
from HOCVIEN hv, monhoc mh, ketquathi kq
where hv.MAHV = kq.MAHV 
and	kq.MAMH = mh.MAMH
and MALOP like 'k%'
and kq.MAMH ='ctrr'
and not exists ( SELECT * FROM KetQuaThi 
		WHERE 
			KETQUATHI.KETQUA = 'Dat' 
			AND MaMH = 'CTRR' 
			and MaHV = hv.MaHV)

--6. Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006
select mh.TENMH, gv.HOTEN,gd.HOCKY,gd.TUNGAY,gd.DENNGAY, gd.MALOP
from GIAOVIEN gv ,GIANGDAY gd , MONHOC mh
where gv.MAGV =gd.MAGV 
and gd.MAMH = mh.MAMH 
and gv.HOTEN = 'tran tam thanh'
and year( gd.TUNGAY) = 2006 and year (gd.denngay) = 2006
and gd.HOCKY =1
--7. Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006
exec danh_sach_giangday
exec danh_sach_giaovien
exec danh_sach_lop
select mh.MAMH, mh.TENMH,gd.HOCKY
from MONHOC mh , GIANGDAY gd
where mh.MAMH = gd.MAMH
and gd.HOCKY = 1
and YEAR (gd.denngay) = 2006
and gd.MAGV = ( select lop.MAGVCN from LOP where LOP.MALOP = 'k11')

--8. Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”
exec danh_sach_hocvien
select (hv.HO+' '+hv.TEN) as [Họ tên], gv.HOTEN, gd.MAMH
from LOP, HOCVIEN hv, GIANGDAY gd, GIAOVIEN gv
where hv.MALOP = LOP.MALOP 
and LOP.MALOP = gd.MALOP
and gv.MAGV = gd.MAGV
and gv.HOTEN = 'Nguyen to lan'
and gd.MAMH ='csdl'
and lop.TRGLOP= hv.MAHV
 --9. In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”
 select mh.MAMH, mh.TENMH, dk.MAMH_TRUOC
 from MONHOC mh , DIEUKIEN dk
 where mh.MAMH = dk.MAMH
 and dk.MAMH = (select MAMH from MONHOC where TENMH = 'co so du lieu')
select * from DIEUKIEN

--10.Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào
 select mh.MAMH, mh.TENMH, dk.MAMH_TRUOC
 from MONHOC mh , DIEUKIEN dk
 where mh.MAMH = dk.MAMH
 and dk.MAMH_TRUOC= (select MAMH from MONHOC where TENMH = 'cau truc roi rac')
select * from DIEUKIEN

SELECT 
	MonHoc.MaMH, MonHoc.TenMH
FROM
	MonHoc, MonHoc AS MonHocTruoc, DieuKien
WHERE
	MonHoc.MaMH = DieuKien.MaMH
	AND MonHocTruoc.MaMH = DieuKien.MaMH_Truoc
	AND MonHocTruoc.TenMH = 'Cau Truc Roi Rac'

--11. Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006
select gv.HOTEN
from GIAOVIEN gv, GIANGDAY gd
where gd.MAGV=gv.MAGV and gd.MALOP ='k11' and gd.HOCKY =1 and year( gd.tungay) = 2006 and year ( gd.denngay)=2006 and gd.MAMH ='ctrr'
intersect 
select gv.HOTEN
from GIAOVIEN gv, GIANGDAY gd
where gd.MAGV=gv.MAGV and gd.MALOP ='k12' and gd.HOCKY =1 and year( gd.tungay) = 2006 and year ( gd.denngay)=2006 and gd.MAMH ='ctrr'

exec danh_sach_giangday
exec danh_sach_giaovien
--12. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này
exec danh_sach_ketquathi
select hv.MAHV, hv.HO+' '+hv.TEN as [Hovaten]
from HOCVIEN hv, KETQUATHI kq
where  hv.MAHV = kq.MAHV
and kq.MAMH ='csdl'
and kq.KETQUA='khong dat'
and kq.LANTHI=1				   
and not exists ( select * from KETQUATHI kq where kq.MAMH ='csdl' and kq.LANTHI >2 and kq.MAHV=hv.MAHV)

--13. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào
select gv.MAGV , gv.HOTEN
from GIAOVIEN gv
except 
select gv.MAGV, gv.hoten
from GIANGDAY gd , GIAOVIEN gv
where gv.MAGV = gd.MAGV

select GIAOVIEN.HOTEN,GIAOVIEN.MAGV
from GIAOVIEN
where GIAOVIEN.MAGV not in ( select GIANGDAY.MAGV from GIANGDAY)

exec danh_sach_giangday
--14. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách
SELECT MaGV, HoTen
FROM GiaoVien
WHERE NOT EXISTS
(
	SELECT *
	FROM MonHoc
	WHERE MonHoc.MaKhoa = GiaoVien.MaKhoa
	AND NOT EXISTS
	(
		SELECT *
		FROM GiangDay
		WHERE GiangDay.MaMH = MonHoc.MaMH
		AND GiangDay.MaGV = GiaoVien.MaGV
	)
)
exec danh_sach_giangday
exec danh_sach_khoa
select * from MONHOC
exec danh_sach_giaovien
--15. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm
select hv.HO, hv.TEN
from HOCVIEN hv,  KETQUATHI kq
where kq.MAHV = hv.MAHV
and kq.LANTHI >=3
and hv.MALOP ='k11'
and kq.KETQUA ='khong dat'
union 
select hv.HO,hv.TEN
from HOCVIEN hv,  KETQUATHI kq
where kq.MAHV = hv.MAHV
and kq.LANTHI =2 
and kq.MAMH ='ctrr'
and kq.DIEM =5

--16. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học
select HOTEN
from GIAOVIEN , GIANGDAY
where 
	GIAOVIEN.MAGV = GIANGDAY.MAGV
	and GIANGDAY.MAMH = 'ctrr'
group by GIAOVIEN.MAGV, GIAOVIEN.HOTEN, GIANGDAY.HOCKY
having count (*) >=2

--17. Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng)
select hv.HO, hv.TEN, kq.DIEM,kq.LANTHI
from KETQUATHI kq, HOCVIEN hv
where hv.MAHV = kq.MAHV
and kq.MAMH ='csdl'
and kq.LANTHI = ( select 
exec danh_sach_ketquathi

SELECT
	HocVien.*, Diem AS 'Điểm thi CSDL sau cùng'
FROM
	HocVien, KetQuaThi
WHERE
	HocVien.MaHV = KetQuaThi.MaHV
	AND MaMH = 'CSDL'
	AND LanThi = 
	(
		SELECT MAX(LanThi) 
		FROM KetQuaThi 
		WHERE MaMH = 'CSDL' AND KetQuaThi.MaHV = HocVien.MaHV 
		GROUP BY MaHV
	)
--18. Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi)
select hv.HO,hv.TEN , max (kq.DIEM) as 'Điêm thi CSDL cao nhất'
from HOCVIEN hv, KETQUATHI kq , MONHOC mh
where hv.MAHV = kq.MAHV
and kq.MAMH = mh.MAMH
and mh.TENMH ='Co so du lieu'
group by hv.HO, hv.TEN

--19.  Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất
select KHOA.*
from KHOA 
where NGTLAP = ( select min (ngtlap) from KHOA)

--20.  Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”
select COUNT (*) AS 'giáo viên có học hàm là “GS” hoặc “PGS”'
from GIAOVIEN 
where HOCHAM in ('GS','PGS')
EXEC danh_sach_giaovien

--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
select khoa.TENKHOA,COUNT (*) AS 'giáo viên học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.'
from GIAOVIEN gv, KHOA
where gv.MAKHOA = KHOA.MAKHOA
and HOCVI in ('cn','ks','ths','ts','pts')
group by KHOA.TENKHOA
--22.  Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt)
select MAMH, KETQUA, count (*) ' số học viên'
from KETQUATHI
group by mamh, KETQUA
order by MAMH

--23.Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học.
exec danh_sach_giangday
exec danh_sach_lop
select distinct gv.MAGV, gv.HOTEN, gd.MALOP,gd.MAMH
from GIAOVIEN gv ,lop, GIANGDAY gd
where gv.MAGV = lop.MAGVCN
and gd.MAGV =gv.MAGV
-- 24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất
select hv.HO, hv.TEN
from HOCVIEN hv, lop
where hv.MALOP = lop.MALOP
and lop.TRGLOP = hv.MAHV
and lop.SISO = ( select max(lop.siso) from lop )

--25. Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi)

SELECT hv.HO,hv.Ten 
FROM HocVien hv , Lop, KetQuaThi kq
WHERE hv.MAHV = Lop.TrgLop
AND hv.MaHV = Kq.MaHV
AND KETQUA = 'Khong Dat'
GROUP BY 
TrgLop, Ho, Ten
HAVING 
COUNT(*) > 3
--26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất
SELECT hv.HO, hv.TEN
FROM HocVien hv , KetQuaThi kq
WHERE hv.MaHV = kq.MaHV
AND Diem >= 9
GROUP BY
hv.MaHV, hv.HO, hv.TEN
HAVING
COUNT(*) >= ALL(SELECT COUNT(*) FROM KetQuaThi WHERE Diem >= 9 GROUP BY MaHV) 
--27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
select lop.MALOP, count (*) AS ' số học viên có số môn đạt 9,10 nhiều nhất'
from hocvien hv , KETQUATHI kq, LOP
where hv.MAHV = kq.MAHV
and hv.MALOP = lop.MALOP
and kq.DIEM >=9
group by lop.MALOP
having count (*)> all (select count (*),lop.MALOP from KETQUATHI kq, lop where  kq.DIEM >= 9 group by lop.MALOP )

select N.MAHV, N.HO,n.TEN,n.MALOP
from ( select  hv.MAHV,hv.HO,hv.TEN, LOP.MALOP, count(*) 'số lượng điểm', rank () over ( partition by lop.malop order by count(*) desc) as xephang
from hocvien hv , KETQUATHI kq, LOP
where hv.MAHV = kq.MAHV
and hv.MALOP = lop.MALOP
and kq.DIEM >=9
group by hv.MAHV,hv.HO,hv.TEN, lop.MALOP) as N
where n.xephang =1
 --28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
SELECT MaGV, COUNT(DISTINCT MaMH) 'Số môn học', COUNT(DISTINCT MALOP) 'Số lớp'
FROM GiangDay
GROUP BY MaGV

 select gv.MAGV, gv.HOTEN, count(*) as [số lượng môn học ],gd.HOCKY, gd.NAM
 from GIAOVIEN gv, GIANGDAY gd
 where gv.MAGV = gd.MAGV 
 group by gv.MAGV, gv.HOTEN,gd.HOCKY,gd.NAM
 union 
 select gv.MAGV, gv.HOTEN , count (*) as [số lượng lớp ],gd.HOCKY, gd.NAM
 from GIAOVIEN gv ,lop, GIANGDAY gd
 where lop.MAGVCN = gv.MAGV
 and gd.MALOP = lop.MALOP 
 group by gv.MAGV,gv.HOTEN,gd.HOCKY, gd.NAM
 exec danh_sach_lop
 exec danh_sach_giangday

 --29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất. 
 select n.MAGV,n.HOCKY, n.NAM 
 from GIAOVIEN gv, (
					select gd.MAGV ,gd.HOCKY, gd.NAM , rank() over  (partition by gd.HOCKY, gd.NAM order by count (*) desc) as Xephang
					from GIANGDAY gd 
					group by gd.magv, gd.hocky, gd.nam
				) as N
 where gv.MAGV = n.MAGV
 and Xephang = 1
 --30.Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất.
 select mh.MAMH,mh.TENMH
 from MONHOC mh, ( select  kq.MAMH , count (*) as sốluong, rank () over (  order by count (*) desc ) as xephang
					from HOCVIEN hv, KETQUATHI kq
					where hv.MAHV = kq.MAHV
					and kq.KETQUA = 'khong dat'
					and kq.LANTHI =1 
					group by  kq.MAMH
					) as N
where mh.MAMH = n.MAMH
and n.xephang =1
--31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1)
select  hv.MAHV, hv.HO ,hv.TEN
from HOCVIEN hv, KETQUATHI kq
where hv.MAHV = kq.MAHV 
and not exists ( select * from KETQUATHI where KETQUATHI.KETQUA = 'khong dat' and KETQUATHI.LANTHI =1 and KETQUATHI.MAHV =hv.MAHV )
group by hv.MAHV, hv.HO ,hv.TEN
-- 32 Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
select  hocvien.MAHV, hocvien.HO ,hocvien.TEN
from HOCVIEN , KETQUATHI 
where HOCVIEN.MAHV = KETQUATHI.MAHV 
and not exists ( select * from KETQUATHI where KETQUATHI.KETQUA = 'khong dat' 
and KETQUATHI.LANTHI = (select max(lanthi)
						from KETQUATHI
						where KETQUATHI.MAHV =MAHV 
						group by MAHV)																				
and KETQUATHI.MAHV = hocvien.MAHV 
)
group by hocvien.MAHV, hocvien.HO ,hocvien.TEN


--33. Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1)
