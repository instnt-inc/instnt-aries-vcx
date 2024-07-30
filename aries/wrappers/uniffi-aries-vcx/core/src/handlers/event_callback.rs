use std::sync::Arc;

pub trait EventListener: Send + Sync {
    fn on_event(&self, event_type: String, event_data: String);
}

pub struct MyEventListener;

impl EventListener for MyEventListener {
    fn on_event(&self, event_type: String, event_data: String) {
        println!("Received event of type: {}, with data: {}", event_type, event_data);
    }
}

pub fn register_listener<T: EventListener>(listener: Arc<T>) {
    // Simulate an event being triggered
    listener.on_event("Type1".to_string(), "Some data".to_string());
}