use esp_idf_svc::hal::delay::Delay;
use esp_idf_svc::hal::prelude::*;
use esp_idf_svc::log::EspLogger;

fn main() {
    esp_idf_svc::sys::link_patches();
    EspLogger::initialize_default();
    let dp = Peripherals::take().unwrap();
    let pins = dp.pins;
    let delay = Delay::default();
    loop {
        delay.delay_ms(100);
    }
}
