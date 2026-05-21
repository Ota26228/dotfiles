#!/bin/sh
  sed 's/WLR_MODIFIER_LOGO/WLR_MODIFIER_ALT/' config.h > config.h.tmp
  cp config.h config.h.main
  cp config.h.tmp config.h
  make
  mv dwl dwl-nested
  cp config.h.main config.h
  rm config.h.tmp config.h.main
