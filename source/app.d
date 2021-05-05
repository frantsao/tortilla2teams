import vibe.http.server;
import vibe.http.router;
import vibe.http.client;
import vibe.stream.operations;
import vibe.web.rest;
import vibe.data.json;
import vibe.data.serialization;
import vibe.core.core : runApplication;
import vibe.core.log;
import std.typecons;
import std.array;
import std.algorithm;
import std.string;
import std.conv;
import std.random;
import std.json;
import std.process : environment;

@path("/api/") interface TortillaAPI {
	@safe string getTortilla();
	@safe Json addTortilla(@viaBody("team") string[] team, 
			@viaBody("invitations") int invitations,
			@viaBody("notificationUrl") string notificationUrl,
			@viaBody("avatarUrl") string avatarUrl,
			@viaBody("themecolor") string themeColor);
	@safe string getHealth();
}

class TortillaAPIService : TortillaAPI {
	@safe string getTortilla()
	{
		return("Send me a POST request and I'll send invitations to eat Spanish tortilla and catch up");
	}


	@safe Json addTortilla(@viaBody("team") string[] team,
			@viaBody("invitations") int invitations,
			@viaBody("notificationUrl") string notificationUrl,
			@viaBody("avatarUrl") string avatarUrl,
			@viaBody("themecolor") string themeColor)
	{

	Json returnMessage;

	if (( invitations >= 1) && (invitations <= team.length)) {
		string buddies;
		string[] table;
		int invitation;
		string separator;
		for (int i = 0; i < invitations; ++i) {
			if (invitations < team.length) {
				invitation=uniform(0,to!int(team.length));
			} else {
				invitation=0;
			}
			table~=team[invitation];
			team=team.remove(invitation);
			if ( i == invitations - 1) {
				separator = "." ;
			} else {
				separator = ", ";
			}
			buddies = buddies ~ table[i] ~ separator;
		}

		struct Fact {
			string name;
			string value;
		}
		struct Section {
			string activityTitle;
			string activityImage;
			Fact[] facts;
			bool markdown;
		}

		auto fact0 = Fact("Invitation for: ", buddies);
		auto section0 = Section("Invitation to tortilla & chat", avatarUrl, [fact0], true);
		Json invitationCard = Json.emptyObject;
		invitationCard["@type"] = "MessageCard";
		invitationCard["@context"] = "http://schema.org/extensions";
		invitationCard["summary"] = "Let's have some tortilla and talk about the weekend";
		invitationCard["themecolor"]= themeColor;
		invitationCard["sections"]=[section0.serializeToJson()];
		// Would be nice serializing invitationCard from a struct but there is a issue with keys beginning with an '@'
		requestHTTP(notificationUrl,
			(scope req) {
				req.method = HTTPMethod.POST;
				req.writeJsonBody(invitationCard);
			},
			(scope res) {
				logInfo("Webhook URL: %s Status code: %s Response: %s", notificationUrl, res.statusCode, res.bodyReader.readAllUTF8());
			}
		);
		returnMessage = Json(["OK": Json("Invitations sent, prepare tortilla and coffee")]);
	} else {
		returnMessage = Json(["Error": Json("Too many invitations, let's have a party!")]);
	}
	return(returnMessage);
	}

	@safe string getHealth()
	{
		return("Healthy!");
	}
}

// API for sandboxing webhook endpoints. We can put MS Teams API
//validations here, but we simply send "sections" to the app log

@path("/sandbox/") interface SandboxAPI {
	@safe Json addTest(Json sections);
}


class SandboxAPIService : SandboxAPI {
	@safe Json addTest(Json sections)
	{
		return(sections);
	}
}

// Main process
void main()
{
    auto router = new URLRouter;
    router.registerRestInterface(new TortillaAPIService);
    router.get("/", (req, res) { res.redirect("/sandbox/test"); } );
    router.get("/api/", (req, res) { res.redirect("/api/tortilla"); } );

    router.registerRestInterface(new SandboxAPIService);

    auto host = environment.get("TORTILLA_HOST", "127.0.0.1");
    auto port = to!ushort(environment.get("TORTILLA_PORT", "9000"));
    auto settings = new HTTPServerSettings;
    settings.port = port;
    settings.bindAddresses = [host];
    settings.errorPageHandler = (req, res, error)
         {
              with(error) res.writeBody(
              format("Code: %s\n Message: %s\n Exception: %s",
              error.code, 
              error.message, 
              error.exception ? error.exception.msg : "¡Petó como una rata!"));
         };  
    auto l = listenHTTP(settings, router);
    scope (exit) l.stopListening();
    runApplication();
}
