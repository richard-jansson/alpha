/* 
 * playback with  play -e signed -b 16 -t raw -c 2 -r 44100 rec.raw
 *
 * using SoX, command line swiss army knife of audio
 */ 
#include<stdio.h>
#include<stdlib.h>
#include<assert.h>
#include<asoundlib.h>

#include"alsarec.h"

int err;
int rate=44100;
snd_pcm_t *handle;
snd_pcm_hw_params_t *hw_params;
snd_pcm_format_t format= SND_PCM_FORMAT_S16_LE;
char *buff,*mono;
int buff_len=44100;
int s;

char *init_rec(int len){
    buff_len=len;

    // open and initialize to one channel and 44100 hertz
    err=snd_pcm_open(&handle,"hw:0,0",SND_PCM_STREAM_CAPTURE,0);
    assert(err>=0);

    err=snd_pcm_hw_params_malloc(&hw_params);
    assert(err>=0);

    err=snd_pcm_hw_params_any(handle,hw_params);
    assert(err>=0);
    
    err=snd_pcm_hw_params_set_access(handle,hw_params,SND_PCM_ACCESS_RW_INTERLEAVED);
    if(err<0){
        fprintf(stderr,"%s\n",snd_strerror(err));
    }
    assert(err>=0);
    err=snd_pcm_hw_params_set_format(handle,hw_params,format);
    assert(err>=0);
    err=snd_pcm_hw_params_set_rate_near(handle,hw_params,&rate,0);
    assert(err>=0);
    
    int rate,dir;
    snd_pcm_hw_params_get_rate(hw_params,&rate,&dir);
    printf("Got rate %i\n",rate);

    err=snd_pcm_hw_params_set_channels(handle,hw_params,2);
    assert(err>=0);

    err=snd_pcm_hw_params(handle,hw_params);
    assert(err>=0);

    snd_pcm_hw_params_free(hw_params);

    snd_pcm_prepare(handle);
    assert(err>=0);
    

    // the actual recording
    FILE *rec=fopen("rec.raw","w");

    s=buff_len*snd_pcm_format_width(format)/8*2;
    buff=malloc(s);
    assert(buff);
    mono=malloc(s/2);
    assert(mono);

    return mono;
}

int close_rec(){
    snd_pcm_close(handle);
    free(buff);
    free(mono);
}

int rec(){
    int r;
    r=snd_pcm_readi(handle,buff,buff_len);
    if(r!=buff_len) printf("buffer underrun\n");
//    printf("read %i\n",r);
    
    if(r%2) r--;

    for(int i=0;i<r;i+=2){
        mono[i]=buff[i*2];
        mono[i+1]=buff[i*2+1];
    }


    return r/2;
}

char *get_buf(){
    return mono;
}

#ifdef TEST
int main(int argc,char *argv[]){

    int r;
    for(int i=0;i<42;i++){
        r=snd_pcm_readi(handle,buff,buff_len);
        if(r!=buff_len) printf("buffer underrun\n");
        fwrite(buff,1,s,rec);
        printf("read %i\n",r);
    }

    snd_pcm_close(handle);

    fclose(rec);
    return 0;
}
#endif
