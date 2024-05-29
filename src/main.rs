use std::error::Error;
use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use configparser::ini::Ini;
use system_shutdown::{force_logout, force_reboot, force_shutdown, hibernate, logout, reboot, shutdown, sleep};


fn load_key() -> Result<String, Box<dyn Error>> {
    let mut config = Ini::new();
    let settings = config.load("config.ini")?;
    let stored_key = settings.get("settings").unwrap().get("key").unwrap().as_ref().expect("Key not found"); 
    println!("Loaded key: {}", stored_key);
    Ok(stored_key.to_string())
}

fn load_address () -> Result<String, Box<dyn Error>> {
    let mut config = Ini::new();
    let settings = config.load("config.ini")?;
    if let Some(ip) = settings.get("settings").unwrap().get("address").unwrap() {
        if let Some(port) = settings.get("settings").unwrap().get("port").unwrap() {
            let address = ip.to_string() + ":" + port;
            println!("Loaded address: {}", address);
            return Ok(address);
        }
    }
    Err(Box::<dyn Error>::from("Address not found"))
}

async fn handle_request(path: web::Path<(String, String)>) -> impl Responder {
    let stored_key: String = load_key().expect("Failed to load config").replace("\"", "");
    let key: &String = &path.0;
    let command: &String;
    if key == &stored_key {
        command = &path.1;
    } else {
        return HttpResponse::Unauthorized().body("Invalid key");
    }
    match command.as_str() {
        "logout" => {
            match logout() {
                Ok(_) => println!("Logging out..."),
                Err(error) => eprintln!("Failed to log out: {}", error),
            }
        },
        "hibernate" => {
            match hibernate() {
                Ok(_) => println!("Hibernating..."),
                Err(error) => eprintln!("Failed to hibernate: {}", error),
            }
        },
        "sleep" => {
            match sleep() {
                Ok(_) => println!("Sleeping..."),
                Err(error) => eprintln!("Failed to sleep: {}", error),
            }
        },
        "reboot" => {
            match reboot() {
                Ok(_) => println!("Rebooting..."),
                Err(error) => eprintln!("Failed to reboot: {}", error),
            }
        },
        "shutdown" => {
            match shutdown() {
                Ok(_) => println!("Shutting down..."),
                Err(error) => eprintln!("Failed to shut down: {}", error),
            }
        },
        _ => {
            return HttpResponse::InternalServerError().body("Unknown command: ".to_string() + command);
        }
    }
    HttpResponse::Ok().body(format!("Received key: {}, command: {}", key, command))
}

async fn handle_force_request (path: web::Path<(String, String)>) -> impl Responder {
    let command = &path.1;
    match command.as_str() {
        "logout" => {
            match force_logout() {
                Ok(_) => println!("Logging out..."),
                Err(error) => eprintln!("Failed to log out: {}", error),
            }
        },
        "reboot" => {
            match force_reboot() {
                Ok(_) => println!("Rebooting..."),
                Err(error) => eprintln!("Failed to reboot: {}", error),
            }
        },
        "shutdown" => {
            match force_shutdown() {
                Ok(_) => println!("Shutting down..."),
                Err(error) => eprintln!("Failed to shut down: {}", error),
            }
        },
        _ => {
            return HttpResponse::InternalServerError().body("Unknown command: ".to_string() + command);
        }
    }
    HttpResponse::Ok().body(format!("Forced command: {}", command))
}

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let address = match load_address() {
        Ok(ok) => ok,
        Err(_) => { 
            println!("Failed to load address, address is set to: 0.0.0.0:8080", ); 
            "0.0.0.0:8080".to_string()
        }, 
    };
    
    HttpServer::new(|| {
        App::new()
            .route("/{key}/{command}", web::get().to(handle_request))
            .route("/{key}/force/{command}", web::get().to(handle_force_request))
    })
    .bind(address)?
    .run()
    .await
}

//https://www.youtube.com/watch?v=Ddrlhgy59fQ