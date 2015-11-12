#![feature(no_std, lang_items)]
#![no_std]

extern crate sel4_sys;
use sel4_sys as seL4;

pub fn _shroom_init() {
    let dma_addr: seL4::types::Word;
    // seL4::Word low, high;
    /* Retrieve boot info from seL4 */
    let boot_info = seL4::getBootInfo();

}

#[no_mangle]
pub extern fn _sel4_main() {
    // start the OS
    _shroom_init();

}

#[lang = "eh_personality"] extern fn eh_personality() {}
#[lang = "panic_fmt"] extern fn panic_fmt() -> ! {loop{}}
