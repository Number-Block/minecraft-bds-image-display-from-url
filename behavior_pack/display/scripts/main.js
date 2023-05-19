import { world, MolangVariableMap } from "@minecraft/server";
import {
  HttpRequest,
  HttpRequestMethod,
  HttpHeader,
  http,
} from "@minecraft/server-net";

const httpServerURL = "http://localhost:8080/minecraft/display";

world.afterEvents.chatSend.subscribe(async (ev) => {
  if (ev.message[0] != "!") return;
  const command = ev.message.split(" ");
  switch (command[0]) {
    case "!display":
      if (!ev.sender.hasTag("displayer")) return;
      const response = await postImageUrl(
        command[1] + " " + command[2] + " " + command[3],
        httpServerURL
      );
      spawnParticles(response, ev.sender);

      ev.sender.runCommand(`execute as @a run tp ~ ~ ~ facing ~ ~ ~-1`);
      break;
    default:
      break;
  }
});

function spawnParticles(response, sender) {
  const responseText = response.body.split("/");
  responseText.forEach((displayInfos) => {
    const displayInfo = displayInfos.split(",");
    if (displayInfo[0] == "") return;
    sender.dimension.spawnParticle(
      "display:pixel",
      {
        x: sender.location.x + parseFloat(displayInfo[3]),
        y: sender.location.y + parseFloat(displayInfo[4]),
        z: sender.location.z,
      },
      new MolangVariableMap().setColorRGB("variable.color", {
        red: parseFloat(displayInfo[0]),
        green: parseFloat(displayInfo[1]),
        blue: parseFloat(displayInfo[2]),
        alpha: 1.0,
      })
    );
  });
}

async function postImageUrl(url, displayServerUrl) {
  try {
    const req = new HttpRequest(displayServerUrl);
    req.method = HttpRequestMethod.POST;
    req.headers = [new HttpHeader("Content-Type", "text/plain")];
    req.body = url;
    const response = await http.request(req);
    return response;
  } catch (_) {}
}
