# notify.sh

This is a shell script tool used for sending push notifications or email notifications and can be easaly called from within other scritps or tools as long as it runs on a UNIX environment.

Integrated with:
 * [Pushover](https://pushover.net) for instant notifications
 * [Pushover Glances](https://pushover.net/api/glances) (for Apple Watch or Android)
 * [Mailgun](https://www.mailgun.com) for emails
 * [Slack](https://slack.com) messages using WebHooks

 ---


		Useage: ./notify.sh option

		  Options are:
		  --mailgun                                                 # email
		    -s|--subject -m|--message -r|--recipients
		  --pushover                                                # push notification
		    -s|--subject -m|--message -p|--priority
		  --glances                                                 # push stats to watchOS
		    -t|--title -m|--message -s|--subtext -c|--count -%|--percent
		  --slack                                                   # push messages to Slack
		    -w|--webhook -c|--channel -u|--username -m|--message
				-p|--priority <good, warning, danger, HEX color value>
		  -h|--help                                                 # display this help message

		NOTE: Notification services credentials
		<pushover_token, pushover_user, mailgun_key, mailgun_domain>
		must be declared using 'export variable="value"' (or add them in the script header)

Shell Example:

	./notify.sh --pushover -s "Downtime Monitor" -m "http://www.yourdomain.com changed status to Offline, recording downtime!" -p 0
	./notify.sh --glances -t "Title here" -m "Message line" -s "Subtext line" -c 57 --percent 99
	./notify.sh --mailgun -s "Hello World" -m "Hello world email body example" -r "user@mail.com, seconduser@mail.com"
	./notify.sh --slack -w "https://hooks.slack.com/services/T0..92/TB..33" -c "#notifications" -u "BOT SCRIPT" -m "Hello World"

Python Example:

	subprocess.call("./notify.sh --pushover -s 'Subject line' -m 'Hello World' -p 1", shell=True)
