#![feature(no_std, lang_items)]
#![no_std]

extern crate sel4_sys;
use sel4_sys as seL4;

#[no_mangle]
pub extern fn _sel4_main() {
//    seL4::InitBootInfo();
}

#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "panic_fmt"] extern fn panic_fmt() -> ! {loop{}}
