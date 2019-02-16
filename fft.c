#include<stdlib.h>
//#include<stdint.h>
#include<kiss_fftr.h>
#include<assert.h>
#include<float.h>

#include"fft.h"

#define NUMFFTS 100
#define TRESH 250000.0
#define RATE 44100

kiss_fft_scalar *rin=NULL;
kiss_fft_cpx *out;
kiss_fftr_cfg kiss;
int blen;

void setup_fft(int len){
   kiss=kiss_fftr_alloc(len*2,0,0,0);
   kiss_fft_scalar *in,*out;
   rin=malloc(len*4*sizeof(kiss_fft_scalar));
   assert(rin);
   blen=len;
}

int do_fft(int16_t *inp){
    assert(rin!=NULL);
    out=malloc(blen*4*sizeof(kiss_fft_cpx));
    assert(out!=NULL);
    for(int i=0;i<blen;i++){
        rin[i]=(float)inp[i]+FLT_MIN;
    }
    for(int i=0;i<NUMFFTS;i++) kiss_fftr(kiss,rin,out);

    float max=FLT_MIN;
    int ind_max=-1;

    for(int i=20;i<blen;i++){
        if(out[i].r>max){
            max=out[i].r;
            ind_max=i;
     }
    }

    free(out);
    int f=(RATE/blen)*ind_max/2;

   return max>TRESH?f:-1;
}

void destroy_fft(){
    free(rin);
}
