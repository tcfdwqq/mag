;A PROCEDURE TO CREATE A BYTE ARRAY FOR MAKING A MOVIE OF
;MAGNETOCONVECTION OR DYNAMOS USING RESULTS FROM PROGRAM mag "me"
;FILES, CONSISTING OF THREE SCALAR FIELDS IN THE EQUATORIAL PLANE
;AS A FUNCTION OF TIME. THIS VERSION DISPLAYS ALL THREE IMAGES AT ONCE
;
;THIS PROCEDURE DISPLAYS RESULTS IN THE EQUATORIAL PLANE
;POSSIBLY ASSUMING SOME LONGITUDINAL SYMMETRY.
;
;THIS PROCEDURE ALSO CREATES JPG FILES OF THE IMAGES, FOR WEB MOVIES.
;
;NOTE: The main byte array containing the images has four dimensions in this
;version, FRAMES=bytarr(nx,ny,3,nframes). This is for reading images from Mac-type
;true-color screen displays, with image dimensions (nx,ny,3). The IDL keyword TRUE=3
;then applies to the TVRD() and WRITE_JPEG commands. This  may have to be modified
;depending on the type of display the image is created on. 
;Consult IDL manual for details.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;SET UP X-WINDOW FOR COLOR DISPLAY
SET_PLOT,'X'
;SET DEVICE FOR COLOR on Mac
DEVICE, RETAIN=2, DECOMPOSED=0

;DEFINE THE VALUE OF PI:
	PI= 3.1415926
;ACCESS RGB-VALUES OF COLOR TABLE
         COMMON COLORS,R_ORIG,G_ORIG,B_ORIG,R_CURR,G_CURR,B_CURR

;THIS VERSION READS TIME AS A STRING VARIABLE
TIME=' '

;READS IN DATA FILENAME
	FILENAME=''
         GIFNAME=''
         GIFFULLNAME=''
	TSTEP=''
	PRINT,'ENTER MOVIE DATA FILENAME:'
	READ,FILENAME

;OPEN DATA FILE AND READ PRELIMINARIES
	OPENR, 1, FILENAME                      ;OPEN FILE FOR READ
	RUNID=' '
	READF,1,RUNID               		;IDENTIFYING HEADER: RUNID
	READF,1,TSCALE,VSCALE                   ;TIME SCALE, VELOCITY SCALE
	READF,1,NR,NI,NPFULL,NSYM,NFRAME        ;RECORD NUMBERS & FRAMES
        PRINT,RUNID
        PRINT,'NR,NI,NPFULL,NSYM,NFRAME= ',NR,NI,NPFULL,NSYM,NFRAME

;DEFAULTS
	NFSTOP=NFRAME-1
	IINTER=0
;NUMBER OF FRAMES TO READ
         PRINT,'Stop at frame NFSTOP ?'
         READ,NFSTOP
;NUMBER OF FRAMES
         NFR=(NFSTOP+2)

;NOTE: NSYM=N-FOLD SYMMETRY IN PHI:
         NP=NPFULL/NSYM
         NPFULL=NPFULL+1                         ;WRAP-AROUND POINT ADDED

;CHOOSE A DISPLAY
	CHOICED=1 & LONSHIFT=0 ;equatorial plane
	PRINT, "EQUATORIAL PLANE DISPLAYS"
	POLAR=1
 
 
;GIF-FILE OPTION
         PRINT,'CREATE JPEG-FILES FOR WEB DISPLAY ?  NO=0  YES=1'
         READ,IGIF
         IF IGIF EQ 1 THEN BEGIN
           PRINT,'ENTER JPG-FILENAME (WITHOUT SUFFIXES):'
           READ,GIFNAME
         ENDIF

;DECLARE COORDINATE ARRAYS
         RAD  = FLTARR(NR)
         PHI   = FLTARR(NPFULL)
         LON   = FLTARR(NPFULL)
;DEFINE DATA ARRAY SIZES
          A1   = FLTARR(NP)
          A2   = FLTARR(NP)
          A3   = FLTARR(NP)
          T    = FLTARR(NR,NPFULL)
          B    = FLTARR(NR,NPFULL)
          W    = FLTARR(NR,NPFULL)

;DEFINE WINDOW SIZE
	 WXSIZE=600 & WYSIZE=200
	PRINT,'SPECIFY  WINDOW SIZE (eg, 600  200):'
         READ,WXSIZE, WYSIZE

;DIMENSION THE BYTE ARRAY FOR TRUE=3
	FRAMES=BYTARR(WXSIZE,WYSIZE,3,NFR)

;CREATE A WINDOW
	WINDOW,2,XSIZE=WXSIZE,YSIZE=WYSIZE
	WSET,2

;READ IN RADII
	READF,1,RAD
        
;create array PHI of longitudes of data points (in radians)
	PI2NP = 2*PI/(NPFULL-1)
	PHI=PI2NP*(FINDGEN(NPFULL))
;converts PHI to array LON from -180 to 180 degrees
	LON=180*PHI/PI - 180.0

;SET UP CONTOUR LEVELS AND COLOR SCHEME

;NUMBER OF CONTOURS
	NLV=17
;SCALE FACTORS
        TSCALE=1.0
        BSCALE=1.0
        WSCALE=1.0
;COLORS
	CTABLE=39                        ; 39: rainbow, 0: black/white
	LOADCT,CTABLE                   ;LOADS COLOR TABLE NUMBER
; SELF-DEFINED COLOR TABLE
; BLACK COLOR AT START OF SPECTRUM
         R_CURR(000)= 00 & G_CURR(000)= 00 & B_CURR(000)= 00
; WHITE COLOR AT END OF SPECTRUM
;       R_CURR(255)=255 & G_CURR(255)=255 & B_CURR(255)=255
; DARK GREY
         R_CURR( 01)= 90 & G_CURR( 01)= 90 & B_CURR( 01)= 90
; LIGHT GREY
         R_CURR( 02)=190 & G_CURR( 02)=190 & B_CURR( 02)=190

         R_CURR( 60)= 35 & G_CURR( 60)=  0 & B_CURR( 60)=230
         R_CURR( 70)= 20 & G_CURR( 70)=  0 & B_CURR( 70)=245
         R_CURR( 80)=  0 & G_CURR( 80)= 60 & B_CURR( 80)=255
         R_CURR( 90)=  0 & G_CURR( 90)=110 & B_CURR( 90)=255
         R_CURR(100)=  0 & G_CURR(100)=150 & B_CURR(100)=255
         R_CURR(110)= 20 & G_CURR(110)=200 & B_CURR(110)=255
         R_CURR(120)= 70 & G_CURR(120)=240 & B_CURR(120)=255
         R_CURR(130)=150 & G_CURR(130)=255 & B_CURR(130)=240
         R_CURR(140)=225 & G_CURR(140)=255 & B_CURR(140)=225

         R_CURR(150)=255 & G_CURR(150)=255 & B_CURR(150)=185
         R_CURR(160)=255 & G_CURR(160)=255 & B_CURR(160)= 75
         R_CURR(170)=255 & G_CURR(170)=225 & B_CURR(170)=  0
         R_CURR(180)=255 & G_CURR(180)=175 & B_CURR(180)=  0
         R_CURR(190)=255 & G_CURR(190)=125 & B_CURR(190)=  0
         R_CURR(192)=255 & G_CURR(192)= 75 & B_CURR(192)=  0
         R_CURR(194)=255 & G_CURR(194)=  0 & B_CURR(194)=  0
         R_CURR(196)=230 & G_CURR(196)=  0 & B_CURR(196)= 35

         TVLCT,R_CURR,G_CURR,B_CURR

   CCOLORS=[70,80,90,100,110,120,130,140,150,160,170,180,190,192,194,196,$
            196,70]

	 !P.THICK=2                      ;DRAWS THICK LINES
	 !P.MULTI=[0,3,0]   ;THREE PLOTS IN A ROW
;        !P.POSITION=[.025,.025,.975,.975] ;ENSURE SQUARE FIGURE
;        XDIM=18.0 & YDIM=6.0
;	 XC1=[1.5/XDIM,1.5/YDIM,16./XDIM,16./YDIM]
 
;************************************************************************
;READ IN DATA ARRAYS FROM MAG DATAFILE INTO IDL ARRAYS.
;**************************************************
;**************************************************
;BEGIN TO MAKE MOVIE
;**************************************************

;MAIN FRAME LOOP
         IFR=-1
         IGIFFR=0
FOR IFRAME=0,NFSTOP-1 DO BEGIN
         IFR=IFR+1
         READF,1,IDAT,TIME
         PRINT,'FRAME= ',IDAT-1,'  TIME= ',TIME

;READ AND MAKE AN IMAGE
  FOR IR=0,NR-1 DO BEGIN 
	READF,1,A1,A2,A3

;ADD TO 2D ARRAYS
     FOR NS=0,NSYM-1 DO BEGIN
        J0=NS*NP
        J1=J0+NP-1
                 T(IR,J0:J1)=A1
                 T(IR,NPFULL-1)=A1(0)
                 B(IR,J0:J1)=A2
                 B(IR,NPFULL-1)=A2(0)
                 W(IR,J0:J1)=A3
                 W(IR,NPFULL-1)=A3(0)
     ENDFOR
 ENDFOR ;END OF IMAGE BUILD
   
;AT FIRST FRAME, SET CONTOURING LEVELS
LABEL0:  IF IFRAME EQ 0 THEN BEGIN
           TMAX=MAX(ABS(T)) / TSCALE
           TSTEP=2*TMAX/(NLV-1)
           TT = FINDGEN(NLV)*TSTEP-TMAX
	   TT(0) = TT(0) - 10*TSTEP  ;DROP FIRST CONTOUR
           BMAX=MAX(ABS(B)) / BSCALE
           BSTEP=2*BMAX/(NLV-1)
           BB = FINDGEN(NLV)*BSTEP-BMAX
	   BB(0) = BB(0) - 10*BSTEP  ;DROP FIRST CONTOUR	
           WMAX=MAX(ABS(W)) / WSCALE
           WSTEP=2*WMAX/(NLV-1)
           WW = FINDGEN(NLV)*WSTEP-WMAX
	   WW(0) = WW(0) - 10*WSTEP  ;DROP FIRST CONTOUR		
          ENDIF

; CONTOUR PLOTS
 ERASE
       MAINID='EQUATORIAL PLANE: TEMPERATURE'
       POLAR_CONTOUR,POLAR*TRANSPOSE(T),PHI,RAD,LEVELS=TT,C_COLORS=CCOLORS,$
		/FILL,XSTYLE=4,YSTYLE=4,TITLE=MAINID,CHARSIZE=1.5 
       POLYFILL,rad(nr-1)*cos(phi),rad(nr-1)*sin(phi),COLOR=0 
       OPLOT,/POLAR,REPLICATE(RAD(0),NPFULL),PHI,COLOR=255 ;DRAW OUTER EQUATOR
       OPLOT,/POLAR,REPLICATE(RAD(NR-1),NPFULL),PHI,COLOR=255 ;DRAW OUTER EQUATOR

       MAINID='AXIAL VORTICITY'
       POLAR_CONTOUR,POLAR*TRANSPOSE(W),PHI,RAD,LEVELS=WW,C_COLORS=CCOLORS,$
		/FILL,XSTYLE=4,YSTYLE=4,TITLE=MAINID,CHARSIZE=1.5 
       POLYFILL,rad(nr-1)*cos(phi),rad(nr-1)*sin(phi),COLOR=0 
       OPLOT,/POLAR,REPLICATE(RAD(0),NPFULL),PHI,COLOR=255 ;DRAW OUTER EQUATOR
       OPLOT,/POLAR,REPLICATE(RAD(NR-1),NPFULL),PHI,COLOR=255 ;DRAW OUTER EQUATOR

       TMSTEP=STRTRIM(IFRAME,1)
       MAINT='AXIAL FIELD AT t= '+ TMSTEP
       POLAR_CONTOUR,POLAR*TRANSPOSE(B),PHI,RAD,LEVELS=BB,C_COLORS=CCOLORS,$
		/FILL,XSTYLE=4,YSTYLE=4,TITLE=MAINT,CHARSIZE=1.5 
       POLYFILL,rad(nr-1)*cos(phi),rad(nr-1)*sin(phi),COLOR=0 
       OPLOT,/POLAR,REPLICATE(RAD(0),NPFULL),PHI,COLOR=255 ;DRAW OUTER EQUATOR
       OPLOT,/POLAR,REPLICATE(RAD(NR-1),NPFULL),PHI,COLOR=255 ;DRAW OUTER EQUATOR

;AT FIRST FRAME OPTION TO CHANGE SCALING OR PROJECTIONS
          IF IFRAME EQ 0 THEN BEGIN
            PRINT,'CHANGE SCALING OR ORIENTATION ?  YES=1'
            READ,IOPT
            IF IOPT EQ 1 THEN BEGIN
              PRINT,'ENTER (Temp, Vort, B)-SCALE FACTORS,  LONGITUDE ?'
              READ,TSCALE,WSCALE,BSCALE,LONSHIFT
            PRINT,'Select Polarity (Reversed=-1; others unchanged):'
	      READ,POLAR1 & IF POLAR1 EQ -1 THEN POLAR=POLAR1
              GOTO, LABEL0
            END
          END

;LOAD IMAGE INTO BYTE ARRAY
	FRAMES(*,*,*,IFR)=TVRD(TRUE=3)

;INCREMENT JPG FILE COUNTER
      IF IGIF EQ 1 THEN IGIFFR=IGIFFR+1
;CREATE JPG FILE
            IF IGIFFR GT 0  THEN BEGIN
             IF IGIFFR LT 10 THEN $
              GIFFULLNAME=GIFNAME+'00'+STRTRIM(FIX(IGIFFR),2)+'.JPG' $
              ELSE IF IGIFFR LT 100 THEN $
              GIFFULLNAME=GIFNAME+'0'+STRTRIM(FIX(IGIFFR),2)+'.JPG'$
              ELSE GIFFULLNAME=GIFNAME+STRTRIM(FIX(IGIFFR),2)+'.JPG'
             WRITE_JPEG,GIFFULLNAME,TVRD(TRUE=3),TRUE=3
            ENDIF


ENDFOR  ;END OF MOVIE CREATION LOOP

CLOSE,1   ;CLOSE DATA FILE



;DISPLAY MOVIE

LABEL20:

PRINT,"MOVIE DISPLAY"

REFRESH=0.1
PRINT,'ENTER REFRESH TIME (nominal 0.1):' 
READ, REFRESH

;RUN MOVIE
FOR N=0,NFR-1 DO BEGIN
	TV, FRAMES(*,*,*,N),TRUE=3
	WAIT,REFRESH
ENDFOR

PRINT,'SHOW AGAIN? (YES=1):'
READ,SHOWMORE
IF (SHOWMORE EQ 1) THEN GOTO, LABEL20

PRINT,"END MAGMOVIE"

;END OF PROCEDURE magmvovEQ3

END
