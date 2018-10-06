A very complex transpose with character numeric variables and counts percents

  METHOD
  ======
     1. use dosubl to proces data one variable at a time
        do vars='var1','var2','var3';
           call symputx('vars',vars);
             rc=dosubl('
               proc sql; * compute counts and append;
     2. Use Arts et all transpose macro
     3. ODS excel proc report.

This uses a nifty transpose by
  Arthur Tabachneck, Xia Ke Shan, Robert Virgile and Joe Whitehurst

This transpose handles mutiple variables that are character and numeric and provides
a nice naming scheme for the many created variables.

see StackOverflow
https://tinyurl.com/ybtex4kd
https://stackoverflow.com/questions/52635826/how-to-get-sas-tabulate-output-into-excel-file


INPUT (looks simple enough)
============================

 WORK.HAVE total obs=16

  VAR1     VAR2    VAR3

  cat       3      yes
  sheep     2      no
  sheep     3      maybe
  pig       3      maybe
  goat      3      maybe
  cat       2      no
  pig       1      no
  cat       2      no
  pig       1      no
  goat      3      no
  cat       3      no
  cat       2      yes
  cat       1      yes
  sheep     3      no
  cat       2      no
  cat       1      maybe

EXAMPLE OUTPUT
==============

 WORK.LOG total obs=3

   VARS    RC            STATUS

   VAR1     0    Processed successfully
   VAR2     0    Processed successfully
   VAR3     0    Processed successfully


 WORK.WANT total obs=3

  VAR     NAM1  CNT1  PCT1     NAM2 CNT2  PCT2      NAM3 CNT3  PCT3     NAM4  CNT4 TOT4  PCT4

  var1    cat     8   0.50     goat   2  0.1250     pig    3  0.1875    sheep   3   16  0.1875
  var2    1       4   0.25     2      5  0.3125     3      7  0.4375            .    .   .
  var3    maybe   4   0.25     no     9  0.5625     yes    3  0.1875            .    .   .


PROCESS
=======

/* just in case uou rerun
proc datasets lib=work;
 delete havall;
run;quit;

%symdel vars / nowarn;
*/

data log;

  do vars='var1','var2','var3';

    call symputx('vars',vars);

     rc=dosubl('
      %let vars=var1;
      proc sql;
        create
           table havSql as
        select
          monotonic() as cat
         ,*
        from (
        select
          "&vars" as var
          ,&vars  length=32 as nam
          ,count(*) as cnt
          ,(select sum(&vars ne "") from have) as tot
          ,calculated cnt/(select sum(&vars ne "") from have) as pct
        from
          have
        group
          by &vars )
      ;quit;

      proc append data=havSQL out=havAll force;
      run;quit;

      %let cc=&syserr;

    ');

    if symgetn('cc') = 0 then status="Processed successfully";
    else status = status="process failed";
    output;

  end;

run;quit;

/*
SQL output - simple computaion of counts and percents

 WORK.HAVSQL total obs=3

 CAT    VAR     NAM      CNT    TOT      PCT

  1     var3    maybe     4      16    0.2500
  2     var3    no        9      16    0.5625
  3     var3    yes       3      16    0.1875
*/

* Arts transpose ;

%utl_transpose(data=havAll, out=wantT, var=nam cnt tot pct,
           by=x,id=cat, var_first=yes)

* prety much done - just use the list ootion in proc report to generate the code below
  and add ods excel;


ods excel file "d:/xls/utl-very-complex-transpose-with-character-numeric-variables-and-counts-percents.xls";

PROC REPORT DATA=WORK.WANTTRN LS=171 PS=65 SPLIT="/" NOCENTER MISSING ;

COLUMN X NAME_1 CNT_1 PERCENT_1 NAME_2 CNT_2 PERCENT_2
 NAME_3 CNT_3 PERCENT_3 NAME_4 CNT_4 TOTAL_4 PERCENT_4;

DEFINE X / DISPLAY FORMAT= $4. WIDTH=4 SPACING=2 LEFT "X" ;
DEFINE NAME_1 / DISPLAY FORMAT= $32. WIDTH=32 SPACING=2 LEFT "NAME" ;
DEFINE CNT_1 / DISPLAY FORMAT= BEST12. WIDTH=12 SPACING=2 RIGHT "CNT" ;
DEFINE PERCENT_1 / DISPLAY FORMAT= BEST12. WIDTH=12 SPACING=2 RIGHT "PERCENT" ;
DEFINE NAME_2 / DISPLAY FORMAT= $32. WIDTH=32 SPACING=2 LEFT "NAME" ;
DEFINE CNT_2 / DISPLAY FORMAT= BEST12. WIDTH=12 SPACING=2 RIGHT "CNT" ;
DEFINE PERCENT_2 / DISPLAY FORMAT= BEST12. WIDTH=12 SPACING=2 RIGHT "PERCENT" ;
DEFINE NAME_3 / DISPLAY FORMAT= $32. WIDTH=32 SPACING=2 LEFT "NAME" ;
DEFINE CNT_3 / DISPLAY FORMAT= BEST12. WIDTH=12 SPACING=2 RIGHT "CNT" ;
DEFINE PERCENT_3 / DISPLAY FORMAT= BEST12. WIDTH=12 SPACING=2 RIGHT "PERCENT" ;
DEFINE NAME_4 / DISPLAY FORMAT= $32. WIDTH=32 SPACING=2 LEFT "NAME" ;
DEFINE CNT_4 / DISPLAY FORMAT= BEST12. WIDTH=12 SPACING=2 RIGHT "CNT" ;
DEFINE TOTAL_4 / DISPLAY FORMAT= BEST12. WIDTH=12 SPACING=2 RIGHT "TOTAL" ;
DEFINE PERCENT_4 / DISPLAY FORMAT= BEST12. WIDTH=12 SPACING=2 RIGHT "PERCENT" ;
RUN;quit;

ods excel close;

OUTPUT
======

see above

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

data have;
length var1 var2 var3 $10;
input var1$ var2$ var3$;
cards4;
cat 3 yes
sheep 2 no
sheep 3 maybe
pig 3 maybe
goat 3 maybe
cat 2 no
pig 1 no
cat 2 no
pig 1 no
goat 3 no
cat 3 no
cat 2 yes
cat 1 yes
sheep 3 no
cat 2 no
cat 1 maybe
;;;;
run;quit;



