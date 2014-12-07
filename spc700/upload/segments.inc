
//define DEBUG_SEGMENTS(1)

scope seg {
  scope bank0 {
    constant start($8000)
    constant end($ffb0)
    variable _pc(start)
  }
  scope bank1 {
    constant start($018000)
    constant end($020000)
    variable _pc(start)
  }
  scope bank2 {
    constant start($028000)
    constant end($030000)
    variable _pc(start)
  }
  scope bank3 {
    constant start($038000)
    constant end($040000)
    variable _pc(start)
  }
  scope bank4 {
    constant start($048000)
    constant end($050000)
    variable _pc(start)
  }
  scope bank5 {
    constant start($058000)
    constant end($060000)
    variable _pc(start)
  }
  scope bank6 {
    constant start($068000)
    constant end($070000)
    variable _pc(start)
  }
  scope bank7 {
    constant start($078000)
    constant end($080000)
    variable _pc(start)
  }
  scope zpage {
    constant start($00)
    constant end($100)
    variable _pc(start)
  }
  scope bss {
    constant start($7e0300)
    constant end($7e2000)
    variable _pc(start)
  }
  scope loram {
    constant start($7e2000)
    constant end($7e8000) // make room for program in ram
    variable _pc(start)
  }
  scope hiram {
    constant start($7f0000)
    constant end($800000)
    variable _pc(start)
  }
  scope sram0 {
    constant start($700000)
    constant end($710000)
    variable _pc(start)
  }

  scope enum {
    constant zpage(0)
    constant bss(1)
    constant loram(2)
    constant hiram(3)
    constant bank0(4)
    constant bank1(5)
    constant bank2(6)
    constant bank3(7)
    constant bank4(8)
    constant bank5(9)
    constant bank6(10)
    constant bank7(11)
    constant sram0(12)
    constant default(-1)
  }
  // default to dummy segment
  variable _current(enum.default) 
  
  macro check_range(variable _pc, define start, define end, define name) {
    if ({end} < _pc || _pc < {start}) {
      // print {name}, " segment overflow\n" // todo
      error {name}, " segment overflow\n" // different output 
      // closing " is displayed with error
      error {name} segment overflow\n also valid"
    }
  }

  macro save_state() {
    print "--------------------------\n"
    if seg._current == seg.enum.bank0 {
        global variable seg.bank0._pc(pc())
        seg.check_range(seg.bank0._pc, seg.bank0.start, seg.bank0.end, "bank0) // todo
        print "  bank0 pc saved at:  "; hex(seg.bank0._pc); print "\n"

    } else if seg._current == seg.enum.bank1 {
        global variable seg.bank1._pc(pc())
        seg.check_range(seg.bank1._pc, seg.bank1.start, seg.bank1.end, "bank1")
        print "  bank1 pc saved at:  "; hex(seg.bank1._pc); print "\n"

    } else if seg._current == seg.enum.bank2 {
        global variable seg.bank2._pc(pc())
        seg.check_range(seg.bank2._pc, seg.bank2.start, seg.bank2.end, "bank2")
        print "  bank2 pc saved at:  "; hex(seg.bank2._pc); print "\n"

    } else if seg._current == seg.enum.bank3 {
        global variable seg.bank3._pc(pc())
        seg.check_range(seg.bank3._pc, seg.bank3.start, seg.bank3.end, "bank3")
        print "  bank3 pc saved at:  "; hex(seg.bank3._pc); print "\n"

    } else if seg._current == seg.enum.bank4 {
        global variable seg.bank4._pc(pc())
        seg.check_range(seg.bank4._pc, seg.bank4.start, seg.bank4.end, "bank4")
        print "  bank4 pc saved at:  "; hex(seg.bank4._pc); print "\n"

    } else if seg._current == seg.enum.bank5 {
        global variable seg.bank5._pc(pc())
        seg.check_range(seg.bank5._pc, seg.bank5.start, seg.bank5.end, "bank5")
        print "  bank5 pc saved at:  "; hex(seg.bank5._pc); print "\n"

    } else if seg._current == seg.enum.bank6 {
        global variable seg.bank6._pc(pc())
        seg.check_range(seg.bank6._pc, seg.bank6.start, seg.bank6.end, "bank6")
        print "  bank6 pc saved at:  "; hex(seg.bank6._pc); print "\n"

    } else if seg._current == seg.enum.bank7 {
        global variable seg.bank7._pc(pc())
        seg.check_range(seg.bank7._pc, seg.bank7.start, seg.bank7.end, "bank7")
        print "  bank7 pc saved at:  "; hex(seg.bank7._pc); print "\n"

    } else if seg._current == seg.enum.zpage {
        global variable seg.zpage._pc(pc())
        seg.check_range(seg.zpage._pc, seg.zpage.start, seg.zpage.end, "zpage")
        print "  zpage pc saved at:  "; hex(seg.zpage._pc); print "\n"
        
    } else if seg._current == seg.enum.bss {
        global variable seg.bss._pc(pc())
        seg.check_range(seg.bss._pc, seg.bss.start, seg.bss.end, "bss")
        print "  bss pc saved at:    "; hex(seg.bss._pc); print "\n"

    } else if seg._current == seg.enum.loram {
        global variable seg.loram._pc(pc())
        seg.check_range(seg.loram._pc, seg.loram.start, seg.loram.end, "loram")
        print "  loram pc saved at:  "; hex(seg.loram._pc); print "\n"

    } else if seg._current == seg.enum.hiram {
        global variable seg.hiram._pc(pc())
        seg.check_range(seg.hiram._pc, seg.hiram.start, seg.hiram.end, "hiram")
        print "  hiram pc saved at:  "; hex(seg.hiram._pc); print "\n"

    } else if seg._current == seg.enum.sram0 {
        global variable seg.sram0._pc(pc())
        seg.check_range(seg.sram0._pc, seg.sram0.start, seg.sram0.end, "sram0")
        print "  sram0 pc saved at:  "; hex(seg.sram0._pc); print "\n"

    } else if seg._current == seg.enum.default {

    } else {
        error "Invalid segment, how'd that happen?\n"
    }
  }
}

macro bank0() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "bank0()\n"
    print "  bank0 pc at:        "; hex(seg.bank0._pc); print "\n"
  }
  output "{ROM_NAME}"
  seek(seg.bank0._pc)
  global variable seg._current(seg.enum.bank0)
}

macro bank1() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "bank1()\n"
    print "  bank1 pc at:        "; hex(seg.bank1._pc); print "\n"
  }
  output "{ROM_NAME}"
  seek(seg.bank1._pc)
  global variable seg._current(seg.enum.bank1)
}

macro bank2() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "bank2()\n"
    print "  bank2 pc at:        "; hex(seg.bank2._pc); print "\n"
  }
  output "{ROM_NAME}"
  seek(seg.bank2._pc)
  global variable seg._current(seg.enum.bank2)
}

macro bank3() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "bank3()\n"
    print "  bank3 pc at:        "; hex(seg.bank3._pc); print "\n"
  }
  output "{ROM_NAME}"
  seek(seg.bank3._pc)
  global variable seg._current(seg.enum.bank3)
}

macro bank4() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "bank4()\n"
    print "  bank4 pc at:        "; hex(seg.bank4._pc); print "\n"
  }
  output "{ROM_NAME}"
  seek(seg.bank4._pc)
  global variable seg._current(seg.enum.bank4)
}

macro bank5() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "bank5()\n"
    print "  bank5 pc at:        "; hex(seg.bank5._pc); print "\n"
  }
  output "{ROM_NAME}"
  seek(seg.bank5._pc)
  global variable seg._current(seg.enum.bank5)
}

macro bank6() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "bank6()\n"
    print "  bank6 pc at:        "; hex(seg.bank6._pc); print "\n"
  }
  output "{ROM_NAME}"
  seek(seg.bank6._pc)
  global variable seg._current(seg.enum.bank6)
}

macro bank7() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "bank7()\n"
    print "  bank7 pc at:        "; hex(seg.bank7._pc); print "\n"
  }
  output "{ROM_NAME}"
  seek(seg.bank7._pc)
  global variable seg._current(seg.enum.bank7)
}

macro zpage() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "zpage()\n"
    print "  zpage pc at:        "; hex(seg.zpage._pc); print "\n"
  }
  output "{_DEVNULL}"
  seek(seg.zpage._pc)
  global variable seg._current(seg.enum.zpage)
}

macro bss() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "bss()\n"
    print "  bss pc at:          "; hex(seg.bss._pc); print "\n"
  }
  output "{_DEVNULL}" // determined by make and passed in as a define
  seek(seg.bss._pc)
  global variable seg._current(seg.enum.bss)
}

macro loram() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "loram()\n"
    print "  loram pc at:        "; hex(seg.loram._pc); print "\n"
  }
  output "{_DEVNULL}"
  seek(seg.loram._pc)
  global variable seg._current(seg.enum.loram)
}

macro hiram() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "hiram()\n"
    print "  hiram pc at:        "; hex(seg.hiram._pc); print "\n"
  }
  output "{_DEVNULL}"
  seek(seg.hiram._pc)
  global variable seg._current(seg.enum.hiram)
}

macro sram0() {
  seg.save_state()
  if {defined DEBUG_SEGMENTS} {
    print "sram0()\n"
    print "  sram0 pc at:        "; hex(seg.sram0._pc); print "\n"
  }
  output "{_DEVNULL}"
  seek(seg.sram0._pc)
  global variable seg._current(seg.enum.sram0)
}

macro hex(variable value) {
  if value > 15 {
    hex(value >> 4)
  }
  value = value & 15
  putchar(value < 10 ? '0' + value : 'a' + value - 10)
}
// vim:ft=bass sts=2
