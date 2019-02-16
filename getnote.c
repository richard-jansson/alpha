#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<errno.h>
#include<stdint.h>

#include "getnote.h"

#define WINDOW 4096

int running=0;
char *buf;
const char *names[]={"C","C#","D","D#","E","F","F#","G","G#","A","A#","B"};
double f0=16.35;


/*
int __getnote(int f){
    long double a=pow(2.0,1.0/12.0);
    long double fr=f/f0;

    long double nf=log(fr)/log(a);
    int n=(int)nf%12;
    int i=nf/12;

//    printf("%i => %s[%i]\n",f,names[n],i);

    return (int)nf;
}
*/

/*
int getnote_init(){
    if(running) return -1;
    buf=init_rec(WINDOW);
    setup_fft(WINDOW);

    return 0;
}
*/

/*
int getnote_freq(){
    int r=rec();
    int freq=do_fft((int16_t*)buf);

    return freq;
}
*/

note_t *getnote_note(int f){
    long double a=pow(2.0,1.0/12.0);
    long double fr=f/f0;

    long double nf=log(fr)/log(a);
    int n=(int)nf%12;
    int i=nf/12;

    note_t *note=malloc(sizeof(note));
    *note->sname=0;
    *note->lname=0;

    strcat(note->sname,names[n]);
//    printf("%s\n",note->sname);
    sprintf(note->lname,"%s[%i]",names[n],i);
    note->f=f;
    note->n=n;
    note->i=i;

    return note;
}

void getnote_freenote(note_t* n){
    free(n);
}

/*void getnote_destroy(){
}
*/

/*
int main(){
    char *buf= init_rec(WINDOW);
    printf("up and running..\n");

    setup_fft(WINDOW);

    
    FILE *out=fopen("out.raw","w");
//    for(int i=0;i<128;i++){
    for(;;){
        int r=rec();

        int note=do_fft((int16_t*)buf);
    
        
//        if(note!=-1) printf("%i\n",note*440/410);
        if(note!=-1) getnote(note*440/410);

        continue;
//        printf("read %i\n",r);
        int w=fwrite(buf,1,r*2,out);
        if(w<r*2){
            fprintf(stderr,"%s\n",strerror(errno));
        }
 //       printf("wrote %i\n",r*2);
    }
    
    fclose(out);
    close_rec();
}
*/
