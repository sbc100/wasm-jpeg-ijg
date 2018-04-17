#
# Copyright 2017 Google LLC. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#


SRCS=jpgglue.c jpgtranscode.c
OBJS=$(SRCS:.c=.o)

LDFLAGS=-s WASM=1 -s ALLOW_MEMORY_GROWTH=1 \
        -s EXPORTED_FUNCTIONS="['_jpg_transcode']"

all: jpgsquash.js

clean:
	rm -f $(OBJS) jpgsquash.js libjpeg.a jpgsquash.wasm

jpegsrc.v7.tar.gz:
	wget http://www.ijg.org/files/jpegsrc.v7.tar.gz

jpeg-7: jpegsrc.v7.tar.gz
	tar xvf jpegsrc.v7.tar.gz

%.o: %.c libjpeg.a
	emcc -c -Ijpeg-7 $(CFLAGS) $(CPPFLAGS) -o $@ $<

libjpeg.a: jpeg-7
	cd jpeg-7 && emconfigure ./configure && make -j8
	cp jpeg-7/.libs/libjpeg.a .

jpgsquash.js: $(OBJS) Makefile
	emcc $(CFLAGS) $(LDFLAGS) -Ljpeg-7/.libs -o $@ $(OBJS) -ljpeg

transcode: $(SRCS) main.c
	$(CC) -o transcode $(SRCS) main.c

run: jpgsquash.js
	emrun --no_browser --port 8000 .


