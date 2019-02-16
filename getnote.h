typedef struct __note_t {
    char sname[3],lname[7];
    int f,n,i;
} note_t;

note_t *getnote_note(int f);
void getnote_freenote(note_t *n);
