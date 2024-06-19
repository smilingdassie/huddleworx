using Microsoft.Graph;
using Microsoft.Identity.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Configuration;

/// <summary>
/// https://www.codeproject.com/Tips/5249834/Demystifying-Microsoft-Graph
/// </summary>


namespace GraphTestDaniel1
{
    class Program
    {

        public static GraphServiceClient graphServiceClient { get; set; }
        public static List<string> lines { get; set; }

        public static List<string> inboxlines { get; set; }

        static void Main(string[] args)
        {
            try
            {
                lines = new List<string>();
                inboxlines = new List<string>();

                Authenticate().Wait();
                //GetTeamsChatMessages().Wait();
                GetMailMessages().Wait();
                //CallDatabaseListOfUsers().Wait();

                System.IO.File.WriteAllLines($"D:\\DANIEL\\SentItemsLogs_{DateTime.Now.ToString("yyyyMMdd_HHmm")}.csv", lines);

                System.IO.File.WriteAllLines($"D:\\DANIEL\\InboxItemsLogs_{DateTime.Now.ToString("yyyyMMdd_HHmm")}.csv", inboxlines);

            }
            catch (MsalUiRequiredException)
            {
                // The application does not have sufficient permissions
                // - did you declare enough app permissions in during the app creation?
                // - did the tenant admin needs to grant permissions to the application.
            }
            catch (MsalServiceException ex) when (ex.Message.Contains("AADSTS70011"))
            {
                // Invalid scope. The scope has to be of the form "https://resourceurl/.default"
                // Mitigation: change the scope to be as expected !
            }
        }


        private static async Task Authenticate()
        {

            var authentication = new
            {
                Authority = ConfigurationManager.AppSettings["Authority"], //"https://graph.microsoft.com",
                Directory = ConfigurationManager.AppSettings["Directory"], //"32d3f70d-b02a-4215-af56-30266d9c88df",
                Application = ConfigurationManager.AppSettings["Application"], //"b97bfd94-0861-42e1-b258-461d14e0a68b",
                ClientSecret = ConfigurationManager.AppSettings["ClientSecret"] //"1aw7Q~g~5B5GA~vnCp4VkHX0.JstUxOl65gkx"
            };

            var app = ConfidentialClientApplicationBuilder.Create(authentication.Application)
                .WithClientSecret(authentication.ClientSecret)
                .WithAuthority(AzureCloudInstance.AzurePublic, authentication.Directory)
                .Build();

            var scopes = new[] { "https://graph.microsoft.com/.default" };

            var authenticationResult = await app.AcquireTokenForClient(scopes)
                .ExecuteAsync();

            graphServiceClient = new GraphServiceClient(
                new DelegateAuthenticationProvider(x =>
                {
                    x.Headers.Authorization = new AuthenticationHeaderValue(
                        "Bearer", authenticationResult.AccessToken);

                    return Task.FromResult(0);
                }));

        }


        //b97bfd94-0861-42e1-b258-461d14e0a68b  //application client id
        //ed20f533-d66d-4e22-9f18-0521eb48fd77  //object id
        //32d3f70d-b02a-4215-af56-30266d9c88df  //directory tenant id
        // ClientSecret = "1aw7Q~g~5B5GA~vnCp4VkHX0.JstUxOl65gkx"
        private static async Task GetMailMessages()
        {



            //var users = await graphServiceClient.Users.Request().GetAsync();
            //https://stackoverflow.com/questions/56707404/microsoft-graph-only-returning-the-first-100-users
            // Create a bucket to hold the users
            List<User> users = new List<User>();

            var usersPage = await graphServiceClient
    .Users
    .Request()
    .Select(user => new
    {
        user.Id,
        user.UserPrincipalName,
        user.DisplayName,
        user.GivenName,
        user.Surname,
        user.Department,
        user.Mail
    })
    //.Filter("userPrincipalName eq 'anil.kalan@sead.co.za'")
    .GetAsync();

            // Add the first page of results to the user list
            users.AddRange(usersPage.CurrentPage);

            // Fetch each page and add those results to the list
            while (usersPage.NextPageRequest != null)
            {
                usersPage = await usersPage.NextPageRequest.GetAsync();
                users.AddRange(usersPage.CurrentPage);
            }


            lines.Add("Date, User, Sender, From, Subject, Recipients, CC Recipients, BCC, RecipNames, CCNames, BCCNames");
            Console.WriteLine("You have this many users:");
            int usercount = users.Count();
            while (usercount > 0)
            {
                Console.Write(".");
                usercount--;
            }
            Console.WriteLine();

            Console.WriteLine("You have processed this many users: (*) indicates an error");
            //set date range: from latest day + 30 days


            bool injectlist = false;

            if (injectlist)
            {
                List<string> injectedUsers = new List<string>();
                injectedUsers.Add("MaxH@sead.co.za");
                injectedUsers.Add("NelisiweM@sead.co.za");
                injectedUsers.Add("NgokholoS@sead.co.za");
                injectedUsers.Add("NikiweM@sead.co.za");
                injectedUsers.Add("NjabuloS@sead.co.za");
                injectedUsers.Add("NkosinathiM@sead.co.za");
                injectedUsers.Add("NkululekoM@sead.co.za");
                injectedUsers.Add("NokubongaN@sead.co.za");
                injectedUsers.Add("NomahlubiD@sead.co.za");
                injectedUsers.Add("NombuleloK@sead.co.za");
                injectedUsers.Add("NompumeleloM@sead.co.za");
                injectedUsers.Add("Nomveliso_tbhivcare.org#EXT#@sead.co.za");
                injectedUsers.Add("Nomvuyo_miet.co.za#EXT#@seadcoza.onmicrosoft.com");
                injectedUsers.Add("NonhlanhlaM@sead.co.za");
                injectedUsers.Add("NonkululekoM@sead.co.za");
                injectedUsers.Add("NosihleM@sead.co.za");
                injectedUsers.Add("office_hb_1@sead.co.za");
                injectedUsers.Add("OneDriveTest@sead.co.za");
                injectedUsers.Add("PatrickM@sead.co.za");
                injectedUsers.Add("PaulK@sead.co.za");
                injectedUsers.Add("PenwellK@sead.co.za");
                injectedUsers.Add("PeterM@sead.co.za");
                injectedUsers.Add("PhumzileZ@sead.co.za");
                injectedUsers.Add("pmtekeza_auruminstitute.org#EXT#@seadcoza.onmicrosoft.com");
                injectedUsers.Add("PozisaM@sead.co.za");
                injectedUsers.Add("qAD4SKHUCVOCjpB@seadcoza.onmicrosoft.com");
                injectedUsers.Add("RamadimetjaM@sead.co.za");
                injectedUsers.Add("RendaniT@sead.co.za");
                injectedUsers.Add("ReneS@clisupport.co.za");
                injectedUsers.Add("Robert.Molale_cli@sead.co.za");
                injectedUsers.Add("RobertM@sead.co.za");
                injectedUsers.Add("SabataM@sead.co.za");
                injectedUsers.Add("SamuelM@sead.co.za");
                injectedUsers.Add("Sandra_tbhivcare.org#EXT#@sead.co.za");
                injectedUsers.Add("sead_admin@sead.co.za");
                injectedUsers.Add("SeadSolutions@sead.co.za");
                injectedUsers.Add("SharonS@sead.co.za");
                injectedUsers.Add("sheilam@sead.co.za");
                injectedUsers.Add("SilethelweT@sead.co.za");
                injectedUsers.Add("SimangaK@sead.co.za");
                injectedUsers.Add("SimoN@sead.co.za");
                injectedUsers.Add("SimosakheX@sead.co.za");
                injectedUsers.Add("SinothileN@sead.co.za");
                injectedUsers.Add("SisiphoN@sead.co.za");
                injectedUsers.Add("SiviweG@sead.co.za");
                injectedUsers.Add("SiviweS@sead.co.za");
                injectedUsers.Add("SiyabongaS@sead.co.za");
                injectedUsers.Add("SiyandaN@sead.co.za");
                injectedUsers.Add("Stephanie.Fourie2_westerncape.gov.za#EXT#@sead.co.za");
                injectedUsers.Add("Sync_SEAD365_a8d5846140f7@seadcoza.onmicrosoft.com");
                injectedUsers.Add("TendaiM@sead.co.za");
                injectedUsers.Add("Terrence.O'rie_westerncape.gov.za#EXT#@sead.co.za");
                injectedUsers.Add("ThaboM@sead.co.za");
                injectedUsers.Add("ThaboMO@sead.co.za");
                injectedUsers.Add("ThakaneD@sead.co.za");
                injectedUsers.Add("ThembekaM@sead.co.za");
                injectedUsers.Add("Thembelihle.Mbatha_auruminstitute.org#EXT#@sead.co.za");
                injectedUsers.Add("ThulaneN@sead.co.za");
                injectedUsers.Add("ThuthukaN@sead.co.za");
                injectedUsers.Add("TimeSheets@sead.co.za");
                injectedUsers.Add("TimT@sead.co.za");
                injectedUsers.Add("TozamaT@sead.co.za");
                injectedUsers.Add("travel@sead.co.za");
                injectedUsers.Add("TshepoM@sead.co.za");
                injectedUsers.Add("vacancies@sead.co.za");
                injectedUsers.Add("VictorM@sead.co.za");
                injectedUsers.Add("VuyiS@sead.co.za");
                injectedUsers.Add("WandiseT@sead.co.za");
                injectedUsers.Add("WelcomeM@sead.co.za");
                injectedUsers.Add("ZamaguguM@sead.co.za");
                injectedUsers.Add("ZaneleK@sead.co.za");
                injectedUsers.Add("ZaneleM@sead.co.za");
                injectedUsers.Add("ZannokwakheM@sead.co.za");
                injectedUsers.Add("zine_miet.co.za#EXT#@seadcoza.onmicrosoft.com");
                injectedUsers.Add("ZiyandaK@sead.co.za");
                injectedUsers.Add("Zodwa.Dam_cli@sead.co.za");
                injectedUsers.Add("ZodwaD@sead.co.za");
                injectedUsers.Add("ZothaM@sead.co.za");
                injectedUsers.Add("ZweliN@sead.co.za");
                injectedUsers.Add("GloriaR@sead.co.za");
                injectedUsers.Add("GraceM@sead.co.za");
                injectedUsers.Add("TozamaT@sead.co.za");
                injectedUsers.Add("PaulK@sead.co.za");
                injectedUsers.Add("kevink@sead.co.za");
                injectedUsers.Add("GraceM@sead.co.za");

                foreach (var user in injectedUsers)//.Where(x=>x.DisplayName.ToLower().Contains("tim")).Take(10))
                {
                    //Console.WriteLine($"{user.Id} - {user.UserPrincipalName} - {user.DisplayName}");

                    
                    string fromDate = ConfigurationManager.AppSettings["FromDate"];
                    string toDate = ConfigurationManager.AppSettings["ToDate"];
                    var filterstring = $"sentDateTime ge {fromDate}T00:00:00Z and sentDateTime le {toDate}T00:00:00Z"; //e.g. 2021-11-01
                    try
                    {
                        //string injecteduser = "TimT@sead.co.za";// "anil.kalan@sead.co.za";
                        //await CallWebApiPerUser(injecteduser, DataRepository.SaveUser(injecteduser, "0"));

                        await CallWebApiPerUser(user, DataRepository.SaveUser(user, user, user), "SentItems", filterstring);

                        await CallWebApiPerUser(user, DataRepository.SaveUser(user, user, user), "Inbox", filterstring);

                        Console.Write(".");
                    }
                    catch (Exception e)
                    {
                        string huh = e.Message;
                        Console.Write("*");
                        string message2 = "";
                        if (e.InnerException != null)
                        {
                            message2 = e.InnerException.Message;
                        }

                        DataRepository.SaveErrorMessage(user, e.Message, message2);
                        Console.WriteLine(huh);
                    }

                }

            }
            else
            {
                foreach (var user in users)//.Where(x=>x.DisplayName.ToLower().Contains("tim")).Take(10))
                {
                    //Console.WriteLine($"{user.Id} - {user.UserPrincipalName} - {user.DisplayName}");

                    DateTime? fromdateT = DataRepository.GetLatestMessageDate(user);
                    string fromDate = fromdateT.Value.ToString("yyyy-MM-dd");//  ConfigurationManager.AppSettings["FromDate"];
                    string toDate = fromdateT.Value.AddDays(30).ToString("yyyy-MM-dd"); // ConfigurationManager.AppSettings["ToDate"];
                    fromDate = ConfigurationManager.AppSettings["FromDate"];
                    toDate = ConfigurationManager.AppSettings["ToDate"];
                    var filterstring = $"sentDateTime ge {fromDate}T00:00:00Z and sentDateTime le {toDate}T00:00:00Z"; //e.g. 2021-11-01
                    try
                    {
                        //string injecteduser = "TimT@sead.co.za";// "anil.kalan@sead.co.za";
                        //await CallWebApiPerUser(injecteduser, DataRepository.SaveUser(injecteduser, "0"));

                        await CallWebApiPerUser(user.UserPrincipalName, DataRepository.SaveUser(user.DisplayName, user.UserPrincipalName, user.Id), "SentItems", filterstring);

                        await CallWebApiPerUser(user.UserPrincipalName, DataRepository.SaveUser(user.DisplayName, user.UserPrincipalName, user.Id), "Inbox", filterstring);

                        Console.Write(".");
                    }
                    catch (Exception e)
                    {
                        string huh = e.Message;
                        Console.Write("*");
                        string message2 = "";
                        if (e.InnerException != null)
                        {
                            message2 = e.InnerException.Message;
                        }

                        DataRepository.SaveErrorMessage(user.UserPrincipalName, e.Message, message2);
                        //Console.WriteLine(huh);
                    }

                }

            }
            Console.ReadKey();
        }

        private static async Task GetTeamsChatMessages()
        {



            //var users = await graphServiceClient.Users.Request().GetAsync();
            //https://stackoverflow.com/questions/56707404/microsoft-graph-only-returning-the-first-100-users
            // Create a bucket to hold the users
            List<User> users = new List<User>();

            var usersPage = await graphServiceClient
    .Users
    .Request()
    .Select(user => new
    {
        user.Id,
        user.UserPrincipalName,
        user.DisplayName,
        user.GivenName,
        user.Surname,
        user.Department,
        user.Mail
    })
    //.Filter("userPrincipalName eq 'anil.kalan@sead.co.za'")
    .GetAsync();

            // Add the first page of results to the user list
            users.AddRange(usersPage.CurrentPage);

            // Fetch each page and add those results to the list
            while (usersPage.NextPageRequest != null)
            {
                usersPage = await usersPage.NextPageRequest.GetAsync();
                users.AddRange(usersPage.CurrentPage);
            }


            lines.Add("Date, User, Sender, From, Subject, Recipients, CC Recipients, BCC, RecipNames, CCNames, BCCNames");
            Console.WriteLine("You have this many users:");
            int usercount = users.Count();
            while (usercount > 0)
            {
                Console.Write(".");
                usercount--;
            }
            Console.WriteLine();

            Console.WriteLine("You have processed this many users: (*) indicates an error");
            //foreach (var user in users.Take(1000000))
            foreach (var user in users)//.Where(x=>x.DisplayName.ToLower().Contains("tim")).Take(10))
            {
                //Console.WriteLine($"{user.Id} - {user.UserPrincipalName} - {user.DisplayName}");

                try
                {
                    await CallTeamsWebApiPerUser(user.UserPrincipalName);

                    //await CallWebApiPerUser(user.UserPrincipalName, DataRepository.SaveUser(user.DisplayName, user.UserPrincipalName, user.Id), "SentItems");

                    //await CallWebApiPerUser(user.UserPrincipalName, DataRepository.SaveUser(user.DisplayName, user.UserPrincipalName, user.Id), "Inbox");

                    Console.Write(".");
                }
                catch (Exception e)
                {
                    string huh = e.Message;
                    Console.Write("*");
                    string message2 = "";
                    if (e.InnerException != null)
                    {
                        message2 = e.InnerException.Message;
                    }

                    DataRepository.SaveErrorMessage(user.UserPrincipalName, e.Message, message2);
                    //Console.WriteLine(huh);
                }

            }
            Console.ReadKey();
        }
        private static async Task CallDatabaseListOfUsers()
        {
            lines.Add("Date, User, Sender, From, Subject, Recipients, CC Recipients, BCC, RecipNames, CCNames, BCCNames");

            using (var db = new HuddleSmtpEntities())
            {
                var users = db.UserPrincipalTables.ToList();//.Where(x=>x.UserEmail== "limontl@sead.co.za" || x.UserEmail == "limont.lehman@sead.co.za").ToList();// db.UsersNotDoneYets.OrderByDescending(x => x.UserEmail).ToList();
                Console.WriteLine("Sent Items");
                foreach (var user in users)
                {
                    try
                    {

                        await CallTeamsWebApiPerUser(user.UserEmail);
                         //   await CallWebApiPerUser(user.UserEmail, DataRepository.SaveUser(user.DisplayName, user.UserEmail, user.UserID), "SentItems");

                            Console.WriteLine(user.UserEmail);
                        
                    }
                    catch (Exception e)
                    {
                        string huh = e.Message;
                        Console.Write("*");
                        string message2 = "";
                        if (e.InnerException != null)
                        {
                            message2 = e.InnerException.Message;
                        }

                        DataRepository.SaveErrorMessage(user.UserEmail, e.Message, message2);
                        Console.WriteLine("Error:" + user.UserEmail + " : "+ huh);
                        if(huh.ToLower().Contains("time"))
                        {
                            Console.ReadKey();
                            
                        }
                      //  
                    }

                }
//                var users1 = db.UserNotDoneYetInboxes.OrderByDescending(x => x.UserEmail).ToList();
                var users1 = db.UserPrincipalTables.Where(x => x.UserEmail == "Amanda.Mohlala@sead.co.za" || x.UserEmail == "AmandaM@sead.co.za").ToList();// db.UsersNotDoneYets.OrderByDescending(x => x.UserEmail).ToList();

                Console.WriteLine("Inbox");
                foreach (var user in users1)
                {
                    try
                    {
                       // await CallWebApiPerUser(user.UserEmail, DataRepository.SaveUser(user.DisplayName, user.UserEmail, user.UserID), "Inbox");

                        Console.WriteLine(user.UserEmail);
                    }
                    catch (Exception e)
                    {
                        string huh = e.Message;
                        Console.Write("*");
                        string message2 = "";
                        if (e.InnerException != null)
                        {
                            message2 = e.InnerException.Message;
                        }

                        DataRepository.SaveErrorMessage(user.UserEmail, e.Message, message2);
                        Console.WriteLine("Error:" + user.UserEmail + " : " + huh);
                        if (huh.ToLower().Contains("time"))
                        {
                            Console.ReadKey();

                        }
                        //  
                    }

                }


                Console.ReadKey();


            }

        }




        private static async Task CallWebApiPerUser(string userid, int userprincipalid, string folderName = "SentItems", string filterstring="")
        {
           
            bool getmessages = true;

            if (getmessages)
            {
                // Create a bucket to hold the users
                List<Message> messages = new List<Message>();

                //ToDo; add inbox

                var messagesPage = await graphServiceClient.Users[userid].MailFolders[folderName]
               .Messages
               .Request()
               .Filter(filterstring)
               .Top(10000)
               .GetAsync();



                // Add the first page of results to the user list
                messages.AddRange(messagesPage.CurrentPage);

                // Fetch each page and add those results to the list
                while (messagesPage.NextPageRequest != null)
                {
                    messagesPage = await messagesPage.NextPageRequest.GetAsync();
                    messages.AddRange(messagesPage.CurrentPage);
                }



                StringBuilder line = new StringBuilder();
                StringBuilder torecipients = new StringBuilder();
                StringBuilder torecipientNames = new StringBuilder();

                StringBuilder ccrecipients = new StringBuilder();
                StringBuilder ccrecipientNames = new StringBuilder();
                StringBuilder bccrecipients = new StringBuilder();
                StringBuilder bccrecipientNames = new StringBuilder();

                foreach (var message in messages)
                {

                    torecipients.Clear();
                    ccrecipients.Clear();
                    bccrecipients.Clear();

                    torecipientNames.Clear();
                    ccrecipientNames.Clear();
                    bccrecipientNames.Clear();


                    line.Clear();
                    line.Append($"{message.SentDateTime}, {userid}, {message.Sender.EmailAddress.Address}, {message.From.EmailAddress.Address},{message.Subject},");


                    foreach (var recip in message.ToRecipients)
                    {
                        torecipients.Append($"{recip.EmailAddress.Address}; ");
                        torecipientNames.Append($"{recip.EmailAddress.Name}; ");
                    }
                    line.Append(torecipients.ToString());
                    line.Append(",");
                    foreach (var recip in message.CcRecipients)
                    {
                        ccrecipients.Append($"{recip.EmailAddress.Address}; ");
                        ccrecipientNames.Append($"{recip.EmailAddress.Name}; ");
                    }
                    line.Append(ccrecipients.ToString());
                    foreach (var recip in message.BccRecipients)
                    {
                        bccrecipients.Append($"{recip.EmailAddress.Address}; ");
                        bccrecipientNames.Append($"{recip.EmailAddress.Name}; ");
                    }
                    line.Append(bccrecipients.ToString());


                    line.Append(torecipientNames.ToString());
                    line.Append(ccrecipientNames.ToString());
                    line.Append(bccrecipientNames.ToString());

                    lines.Add(line.ToString());

                    string huh = message.Id;

                    DataRepository.SaveEmail(folderName, userid, userprincipalid, message.Sender.EmailAddress.Address, message.From.EmailAddress.Address, torecipients.ToString(), ccrecipients.ToString(), bccrecipients.ToString(), message.Subject, message.SentDateTime.Value.DateTime, torecipientNames.ToString(), ccrecipientNames.ToString(), bccrecipientNames.ToString());

                }
            }

        }


        private static async Task CallTeamsWebApiPerUser(string userid)
        {
            string fromDate = ConfigurationManager.AppSettings["FromDate"];
            string toDate = ConfigurationManager.AppSettings["ToDate"];

            var filterstring = $"sentDateTime ge {fromDate}T00:00:00Z and sentDateTime le {toDate}T00:00:00Z"; //e.g. 2021-11-01

            bool getmessages = true;

            if (getmessages)
            {
                // Create a bucket to hold the users
                List<Message> messages = new List<Message>();

                //ToDo; add inbox


                List<Microsoft.Graph.ChatMessage> cms = new List<ChatMessage>();


                var chats = graphServiceClient.Users[userid].Chats.Request().GetAsync().Result;

                var joinedTeams = graphServiceClient.Users[userid].JoinedTeams
               .Request()
               .GetAsync().Result;

                var joinedGroups = graphServiceClient.Users[userid].MemberOf
              .Request()
              .GetAsync().Result;

                List<Microsoft.Graph.Team> teams = new List<Microsoft.Graph.Team>();
                    teams.AddRange(joinedTeams.CurrentPage);

                List<Microsoft.Graph.Group> groups = new List<Microsoft.Graph.Group>();
                foreach (var item in joinedGroups)
                {
                    groups.Add( (Group)item);
                }


                foreach (var team in teams)
                {
                    if (team.Channels != null)
                    {
                        foreach (var chanel in team.Channels)
                        {
                            foreach (var message in chanel.Messages)
                            {
                                var from = message.From;
                            }
                        }
                    }
                }

                foreach (var group in groups)
                {
                    if (group.Threads != null)
                    {
                        foreach (var thread in group.Threads)
                        {
                            foreach (var post in thread.Posts)
                            {
                                var from = post.From;
                            }
                        }
                    }
                }




            }

        }


    }
}
