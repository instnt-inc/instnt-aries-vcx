pub trait EventListener {
    fn on_event(&self, event_type: String, event_data: String);
}

pub struct MyEventListener;

impl EventListener for MyEventListener {
    fn on_event(&self, event_type: String, event_data: String) {
        println!("Received event of type: {}, with data: {}", event_type, event_data);
    }
}