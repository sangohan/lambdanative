#|
LambdaNative - a cross-platform Scheme framework
Copyright (c) 2009-2015, University of British Columbia
All rights reserved.

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the
following conditions are met:

* Redistributions of source code must retain the above
copyright notice, this list of conditions and the following
disclaimer.

* Redistributions in binary form must reproduce the above
copyright notice, this list of conditions and the following
disclaimer in the documentation and/or other materials
provided with the distribution.

* Neither the name of the University of British Columbia nor
the names of its contributors may be used to endorse or
promote products derived from this software without specific
prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#

(c-declare #<<end-of-c-declare

#ifdef IOS
  extern char localnotification_msg[100];
  extern double localnotification_timestamp;
  extern int localnotification_gotmsg;
  int ios_localnotification_schedule(char*, double);
  void ios_localnotification_cancelall();
#elif ANDROID
  extern char localnotification_msg[100];
  extern double localnotification_timestamp;
  extern int localnotification_gotmsg;
  int android_localnotification_schedule(char*, double);
#else
  char localnotification_msg[100];
  double localnotification_timestamp = 0;
  int localnotification_gotmsg = 0;
#endif

int localnotification_schedule(char* text, double time){
#ifdef IOS
  ios_localnotification_schedule(text, time);
#elif ANDROID
  android_localnotification_schedule(text, time);
#endif
  return 0;
}

void localnotification_cancelall(){
#ifdef IOS
  ios_localnotification_cancelall();
#elif ANDROID
#endif
}

void localnotification_resetmsg(){
  localnotification_gotmsg = 0;
}

end-of-c-declare
)

;; Internal variables
(define localnotification:msg "")
(define localnotification:timestamp 0.)

;; Create local notification
(define (localnotification-schedule str time)
  (if (and (> time ##now) (string? str) (fx<= (string-length str) 100))
    ((c-lambda (char-string double) bool "___result=localnotification_schedule(___arg1,___arg2);") str time)
    #f
  ))

;; Clear notifications
(define (localnotification-cancelall)
  ((c-lambda () void "localnotification_cancelall")))

;; Retrieve local notification
(define (localnotification-getalert)
  (if ((c-lambda () bool "___result=localnotification_gotmsg;"))
    (begin
      ((c-lambda () void "localnotification_resetmsg"))
      (set! localnotification:msg ((c-lambda () char-string "___result=localnotification_msg;")))
      (set! localnotification:timestamp ((c-lambda () double "___result=localnotification_timestamp;")))
      localnotification:msg
    )
    #f
  ))

;;eof
