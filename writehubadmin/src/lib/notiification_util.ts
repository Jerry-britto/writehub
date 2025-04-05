export default async function sendNotification(token: string, title: string, body: string) {
    try {
        const response = await fetch("http://localhost:5000/send-notification", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              token,
              title,  
              body,   
            }),
        });

        const data = await response.json();
        
        if (response.ok) {
            console.log("Notification sent successfully:", data);
        } else {
            console.error("Failed to send notification:", data);
        }

    } catch (error) {
        console.error("Could not send notification:\n", error);
        return { error: "Failed to send notification" };
    }
}
