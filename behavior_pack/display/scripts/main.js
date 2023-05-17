import { world } from "@minecraft/server";
import {
  HttpRequest,
  HttpRequestMethod,
  HttpHeader,
  http,
} from "@minecraft/server-net";

const displayServerUrl = "http://localhost:8080/minecraft/display";

world.afterEvents.chatSend.subscribe(async (ev) => {
  if (ev.message[0] != "!") return;
  const command = ev.message.split(" ");
  switch (command[0]) {
    case "!display":
      if (!ev.sender.hasTag("displayer")) return;
      const response = await postImageUrl(
        command[1] + " " + command[2] + " " + command[3]
      );

      const displayCommands = response.body.split("/");
      displayCommands.forEach((displayCommad) => {
        if (displayCommad == "") return;
        ev.sender.runCommand(displayCommad);
      });
      ev.sender.runCommand(`execute as @a run tp ~ ~ ~ facing ~ ~ ~-1`);
      break;
    default:
      break;
  }
});

async function postImageUrl(url) {
  try {
    const req = new HttpRequest(displayServerUrl);
    req.method = HttpRequestMethod.POST;
    req.headers = [new HttpHeader("Content-Type", "text/plain")];
    req.body = url;
    const response = await http.request(req);
    return response;
  } catch (_) {}
}
