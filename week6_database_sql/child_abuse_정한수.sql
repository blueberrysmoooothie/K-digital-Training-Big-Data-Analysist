-- create database child_abuse_db;
-- use child_abuse_db; 

show tables;

#연령별 피해 아동수 테이블 합치기
select * from child_count_01_17;
select * from child_count_18_20 cc;

select 시점, 소계,`1세 미만`+1세+2세 as `0세~2세`, 3세+4세+5세 as `3세~5세` , 6세+7세+8세 as `6세~8세`, 
		9세+10세+11세 as `9세~11세`, 12세+13세+14세 as `12세~14세`, 15세+16세+17세 as `15세~17세`
from child_count_18_20 cc;

create table child_count
as (select 시점, 소계, `0세~2세`, `3세~5세` , `6세~8세`, `9세~11세`, `12세~14세`, `15세~17세`
	from child_count_01_17);

insert into child_count
	select 시점, 소계,`1세 미만`+1세+2세 as `0세~2세`, 3세+4세+5세 as `3세~5세` , 6세+7세+8세 as `6세~8세`, 
			9세+10세+11세 as `9세~11세`, 12세+13세+14세 as `12세~14세`, 15세+16세+17세 as `15세~17세`
	from child_count_18_20 cc;

# 기본키 설정
alter table child_count
modify 시점 year PRIMARY key not null;

-- drop table child_count_01_17;
-- drop table child_count_18_20;


#학대 유형별 발생 건수 테이블 합치기
select * from types_01_07;
select * from types_18_20;

create table types
as (select 시점,	계,	신체학대,	정서학대,	성학대,	방임
	from types_01_07
	union
	select *
	from types_18_20);

alter table types
modify 시점 year PRIMARY key not null;

-- drop table types_01_07;
-- drop table types_18_20;


# 가해자 유형별 발생 건수 테이블 합치기
select * from gaheja_01_17;
select * from gaheja_18_20;

update gaheja_01_17
set 대리양육자 = null
where 대리양육자 = '-';

alter table gaheja_01_17
modify 대리양육자 int;

create table gaheja
as (select 시점, 부모, 친인척, 대리양육자, 기타
	from gaheja_01_17
	union
	select *
	from gaheja_18_20);

alter table gaheja
modify 시점 year PRIMARY key not null;

-- drop table gaheja_01_17;
-- drop table gaheja_18_20;

drop table law_history;


create table law_history
(	ind smallint unsigned primary key auto_increment,
	시점 year,
	set_date date,
	short_dis varchar(20),
	detail text,
	constraint foreign_key_checks foreign key (시점)
	references types(시점)
);


# 개정/재정 일자,  시행내용, 이유
insert into law_history
(set_date ,	short_dis ,	detail)
values
('2000-07-13', '아동복지법 전문개정', '우리 사회의 아동복지수요에 능동적으로 대응하고 최근 심각한 사회문제로 지적된 바 있는 학대아동에 대한 보호 및 아동안전에 대한 제도적 지원을 공고히 하기 위하여 아동복지지도원을 별정직공무원에서 사회복지전담공무원으로 그 신분을 변경하고, 아동학대에 대한 정의와 금지유형을 명확히 규정하며, 아동학대에 대한 신고를 의무화하는등 기타 현행 규정의 운영상 나타난 일부 미비점을 개선·보완'),
('2004-07-30', '아동복지법 일부개정','아동의 권리증진과 건강한 출생 및 성장을 위해 종합적인 아동정책을 수립하고 관계부처의 의견을 조정하며 그 정책의 이행을 감독하고 평가하기 위하여 국무총리 소속하에 아동정책조정위원회를 두도록 하고, 상습적으로 아동을 학대행위를 한 자 등에 대한 형을 2분의 1까지 가중하도록 하는 등 현행제도의 운영상 나타난 일부 미비점을 개선·보완'),
('2006-01-14', '아동복지법 일부개정', '보호를 필요로 하는 아동에 대한 가정위탁보호를 활성화할 수 있도록 가정위탁지원센터 등을 두고, 아동학대를 근절하기 위하여 현재 아동학대 신고의무자로 되어 있는 교원, 의료인, 아동복지시설 종사자 등의 자격취득 교육과정에 관계 중앙행정기관의 장으로 하여금 아동학대 예방 및 신고와 관련된 교육내용을 포함시키도록 하는 등 현행 제도의 운영상 나타난 일부 미비점을 개선·보완'),
('2007-03-28', '아동복지법 일부개정', '전문치료기관 또는 요양소에 입원 또는 입소시킬 수 있도록 하고, 아동학대 신고의무자의 범위에 유치원·학원·교습소의 운영자·교직원·종사자 등과 구급대의 대원을 추가하는 등 아동의 안전하고 건전한 성장환경을 조성'),
('2008-12-14', '아동복지법 일부개정', '실종ㆍ유괴 예방 교육을 실시하고, 아동보호구역에 폐쇄회로 텔레비전을 설치하거나 그 밖의 필요한 조치를 할 수 있도록 하는 등 아동이 안전하고 건전하게 성장할 수 있는 환경을 조성'),
('2012-08-05', '아동복지법 전부개정', '아동종합실태조사를 시행하여 그 결과를 바탕으로 아동정책기본계획을 수립·시행하고, 아동학대의 예방과 방지, 아동학대행위자의 계도를 위한 교육 등에 관한 홍보영상을 방송할 수 있도록 하며, 아동복지서비스의 안정적 추진을 위한 근거와 아동정책을 효과적으로 수행하기 위한 정책적 기반을 마련함으로써, 아동의 복지증진을 통해 아동이 건강하고 행복하게 자랄 수 있도록 하려는 것'),
('2013-01-23', '아동복지법 일부개정', '아동보호구역에 영상정보처리기기(CCTV)를 설치할 수 있도록 재량사항으로 규정하고 있어 예산부족 등을 이유로 영상정보처리기기가 설치가 원활히 이루어지고 있지 않은바, 모든 아동보호구역에 영상정보처리기기 설치를 의무화함으로써 아동이 안전하게 성장할 수 있는 환경을 조성하는 한편, 아동학대 신고의무자의 신고의무 위반 시 부과하는 과태료 상한을 현행 100만원에서 300만원으로 상향조정함으로써 학대아동에 대한 법적 보호와 구제의 실효성을 높이려는 것'),
('2014-09-29', '아동복지법 일부개정', '아동학대범죄의 처벌 등에 관한 특례법」에 따라 관련 조문을 정비하고, 아동학대 관련 범죄전력자가 아동관련기관에 취업하는 것을 10년 동안 제한하는 등 아동학대의 예방 및 피해자 지원에 관한 내용을 정함'),
('2015-09-28', '아동복지법 일부개정', '피해아동의 가족 구성원 파악을 통한 사후조치를 실효성 있게 하도록 아동보호전문기관의 장의 신분조회 등 조치의 범위에 가족관계등록부의 증명서를 포함하고, 아동학대를 1차적으로 발견할 수 있는 사람인 아동학대 신고의무자에 대한 신고의무 고지 및 교육을 강화하며, 아동에 대한 체벌 등의 금지'),
('2016-06-30', '아동복지법 일부개정', '아동에 대해 감염병 예방 등 보건위생관리에 관한 교육을 실시하여 감염을 스스로 방지하고, 사전에 차단할 수 있도록 교육하는 법적근거를 마련'),
('2016-09-23', '아동복지법 일부개정', '시설 이용자의 권익 보호 조치를 법률로 규정하고, 원칙적으로 아동이 원가정에서 성장하도록 지원하는 등 아동보호서비스의 원칙을 명시하고 보호대상아동에 대한 사전 조사ㆍ상담 등 보호조치에 필요한 구체적인 내용을 정하여 보호대상아동에 대한 보호조치를 강화하고 아동의 복리를 증진, 동보호전문기관이 피해아동의 가족 기능 회복을 위한 업무를 실효적으로 수행할 수 있도록 하며, 아동의 심리안정을 도모하고 2차 피해를 방지하기 위해 아동보호전문기관 내 진술녹화실을 설치하여 운영하고, 학대피해아동쉼터에 대한 법적 근거를 마련하며, 아동보호전문기관을 아동복지시설에 포함함으로써 여타 사회복지시설처럼 운영ㆍ회계에 대한 정부의 관리ㆍ감독을 강화하고, 실태조사에 대한 근거규정을 정비'),
('2017-12-20', '아동복지법 일부개정', '아동복지심의위원회의 구성 및 운영 현황을 연 1회 보건복지부장관에게 보고하도록 하고, 아동을 대상으로 교육 및 보호 등을 수행하는 기관임에도 불구하고 아동학대 관련 범죄전력자의 취업제한 대상기관에서 제외되어 있는 학습부진아 교육 실시기관, 소년원 및 소년분류심사원을 포함하여 아동보호의 사각지대를 해소하고 아동학대를 적극 예방'),
('2018-04-25', '아동복지법 일부개정', '모든 신고의무자에 대하여 소속 기관 및 시설의 장이 교육을 실시하도록 하고, 아동학대 예방에 대한 사회의 인식 제고를 위하여 국가기관, 공공기관 등에서 매년 아동학대 예방교육을 실시하도록 하는 한편, 학생에 대한 학대의 조기 발견과 신속한 보호조치를 위하여 기관 간 연계 체계 구축 및 정보 공유를 하도록 하고, 학대피해아동에 대한 법률상담 지원 및 아동학대 전담의료기관 지정 근거를 마련하여 학대피해아동에 대한 지원을 강화'),
('2019-06-12', '아동복지법 일부개정', '법원이 아동학대관련범죄로 형 등을 선고할 때 최장 10년의 기간 범위 내에서 아동관련기관에의 취업제한 명령을 선고하는 등의 조치를 마련함으로써 위헌성을 해소하고, 이러한 취업제한 명령을 선고받은 자의 아동관련기관 취업 여부 연 1회 이상 점검ㆍ확인 대상에 아동관련기관 운영자도 법률에 포함, 피해아동, 그 보호자 또는 아동학대행위자에 대한 각종 증명서 발급 등에 소요되는 수수료를 면제'),
('2019-07-16', '아동복지법 일부개정', '아동권리보장원을 설립하여 보호가 필요한 아동이 발견되어 보호종료 이후까지 이어지는 전 과정을 총괄적, 체계적으로 지원, 현행법에서는 아동학대 관련 정보 관리를 위해 운영 중인 국가아동학대정보시스템을 중앙아동보호전문기관에서 위탁하고 있는데, 이를 정보시스템 관리ㆍ운영에 전문성을 가지고 있는 사회보장정보원에 위탁하도록 함.'),
('2020-10-01', '아동복지법 일부개정', '아동학대 조사체계를 공공 중심으로 개편하여 조사의 내실을 기하고 아동보호를 강화하는 한편, 아동학대 관련 범죄로 형 또는 치료감호를 선고받은 자의 취업제한대상기관을 추가하고, 아동학대 예방 등을 위한 홍보영상 송출범위를 확대하는 등 현행 제도의 운영상 나타난 일부 미비점을 개선ㆍ보완'),
('2021-03-30', '아동복지법 일부개정', '학대 고위험군 아동을 예측하는 시스템인 ‘e아동행복지원시스템’의 구축 근거를 마련하고, 학대 고위험군 아동 정보를 토대로 하여 보건복지부장관 및 시장ㆍ군수ㆍ구청장으로 하여금 양육환경 조사, 복지서비스 제공, 수사기관 또는 아동보호전문기관과의 연계 등의 조치를 실시하도록 하며, 보건복지부ㆍ교육부ㆍ지방자치단체 등 관계 부처 간 학대 고위험군 아동에 대한 정보공유를 강화,  보호자로부터 피해아동을 즉시 분리할 수 있는 제도를 마련하고, 시장ㆍ군수ㆍ구청장이 보호대상아동의 가정 복귀여부를 결정할 때 아동보호전문기관의 장, 아동을 상담ㆍ치료한 의사 등의 의견을 존중하도록 하며, 아동학대행위자가 상담ㆍ교육ㆍ심리적 치료 등을 받지 않은 경우에는 원가정 복귀를 취소할 수 있도록 함, 에 아동보호전문기관이 아동학대 재발 방지를 위해 실시하는 사후관리 업무를 정당한 사유 없이 거부ㆍ방해하는 사람에게 제재수단을 마련하여 사후관리의 실효성을 제고'),
('2022-06-22', '아동복지법 일부개정', '《보호종료아동 자립지원 강화 방안》을 발표하여 이들에 대한 자립지원을 강화, 보호대상아동의 의사를 존중하여 본인의 의사에 따라 아동복지시설 등에서의 보호조치 기간을 최대 24세까지로 연장할 수 있도록 하고, 보호종료아동 실태조사 관련 규정을 법률에 명시하여 조사의 내실화를 기하며, 자립지원전담기관 설치ㆍ운영 근거와 보호종료아동에 대한 자립정착금 및 자립수당 지급근거 등을 마련, 아동학대관련범죄로 형 또는 치료감호를 선고받은 경우 일정기간 취업을 제한하는 기관에 산후조리도우미 서비스를 제공하는 사람을 모집하거나 채용하는 기관을 추가,「가정폭력범죄의 처벌 등에 관한 특례법」에 따른 가정폭력에 아동을 노출시키는 행위를 정서적 학대의 한 형태로 규정, 아동종합실태조사의 실시주기를 5년에서 3년으로 변경하며, 국가와 지방자치단체로 하여금 매년 물가상승률 등을 반영한 급식최저단가를 결정하도록 하고, 급식지원 시 이를 반영하도록 하며, 국가 또는 지방자치단체가 아동복지시설을 폐업 또는 휴업 처분을 하는 경우에는 해당 시설을 이용하는 아동에게 충분히 설명하고, 해당 아동의 의견을 반영하여 이에 따른 전원조치가 이루어지도록 하되, 구체적인 사항은 대통령령으로 규정'),
('2014-01-28', '아동학대 처벌법 제정', '아동학대범죄의 처벌 등에 관한 특례법: 아동학대범죄의 처벌 및 그 절차에 관한 특례와 피해아동에 대한 보호절차 및 아동학대행위자에 대한 보호처분을 규정함으로써 아동을 보호하여 아동이 건강한 사회 구성원으로 성장하도록 함을 목적으로 한다.'),
('2016-01-25', '아동학대 처벌법 전부개정', '어려운 용어를 쉬운 용어로 바꾸어 국민이 법을 이해하기 쉽게 정비'),
('2016-11-30', '아동학대 처벌법 일부개정', '신고자 등이 신고로 인한 피해를 입지 않도록 함'),
('2017-05-30', '아동학대 처벌법 전부개정', '현행 법률상 미흡한 점을 개선ㆍ보완'),
('2018-06-20', '아동학대 처벌법 일부개정', '정서적ㆍ심리적 차원의 피해아동 보호 규정을 보완, 처벌을 강화'),
('2019-07-16', '아동학대 처벌법 일부개정', '보호가 필요한 아동이 발견되어 보호종료 이후까지 이어지는 전 과정을 총괄적, 체계적으로 지원, 다함께돌봄센터를 설치ㆍ운영할 수 있는 법적 근거를 마련'),
('2020-10-01', '아동학대 처벌법 일부개정','아동보호의 공백이 발생하지 않도록 하는 등 현행 제도의 운영상 나타난 일부 미비점을 개선ㆍ보완'),
('2021-01-26', '아동학대 처벌법 일부개정', '현장출동, 현장조사 및 응급조치 등 현행법상 아동학대사건 대응 절차의 미비점을 개선ㆍ보완함으로써 아동학대범죄를 예방하고 피해아동 보호를 강화'),
('2021-03-16', '아동학대 처벌법 일부개정', '아동학대살해죄를 신설하여 이를 가중처벌하는 한편, 피해아동에 대한 국선변호사 및 국선보조인의 선정을 의무화하여 아동학대범죄의 수사 및 재판 과정에서 피해아동의 권익을 보다 두텁게 보호');

set foreign_key_checks=0;
update law_history
	set 시점 = year(set_date);
set foreign_key_checks=1;





select * from law_history
order by 시점;


select * from law_history
where detail like '%처벌%'
order by 시점;

select * from law_history
where detail like '%신고%'
order by 시점;

select * from law_history
where detail like '%보호%'
order by 시점;

select * from law_history
where short_dis like '%전부%' or
		short_dis like '%전문%' or
		short_dis like '%제정%'
order by history_year ;

select * from law_history 
where 시점 = 2013;

select * from law_history 
where 시점 > 2013 and detail like '%보호%';

