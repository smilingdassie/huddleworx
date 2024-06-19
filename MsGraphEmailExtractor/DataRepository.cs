using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.Entity;
using Microsoft.Graph;

namespace GraphTestDaniel1
{
    static class DataRepository
    {
        //test
        public static DateTime? GetLatestMessageDate(User user)
        {
            DateTime? result = null;
            using (var db = new HuddleSmtpEntities())
            {
                var results = db.SentEmails.Where(x => x.UserEmail == user.UserPrincipalName).OrderByDescending(x => x.DateTimeSent);//.First().DateTimeSent;
                if (!results.Any())
                {
                    results = db.SentEmails.OrderByDescending(x => x.DateTimeSent);
                }
                result = results.First().DateTimeSent;
            }

            return result;
        }

        public static int SaveUser(string DisplayName, string Email, string UserID)
        {
            using (var db = new HuddleSmtpEntities())
            {
                UserPrincipalTable user = new UserPrincipalTable();
                user.DateTimeImported = DateTime.Now;
                user.UserID = UserID;
                user.DisplayName = DisplayName;
                user.UserEmail = Email;
                db.UserPrincipalTables.Add(user);
                db.SaveChanges();
                return user.ID;
            }

        }

        public static int SaveEmail(string folderName, string Email, int UserID, string Sender, string FromEmail, string ToEmail, string CCEmail, string BCCEmail, string Subject, DateTime DateTimeSent, string ToEmailNames, string CCEmailNames, string BCCEmailNames)
        {

            try
            {

                if (folderName == "SentItems")
                {
                    using (var db = new HuddleSmtpEntities())
                    {
                        SentEmail sentEmail = new SentEmail();
                        sentEmail.Sender = Sender;
                        sentEmail.FromEmail = FromEmail;
                        sentEmail.DateTimeImported = DateTime.Now;
                        sentEmail.UserPrincipalID = UserID;
                        sentEmail.UserEmail = Email;
                        sentEmail.Subject = Subject;
                        sentEmail.CCEmail = CCEmail;
                        sentEmail.ToEmail = ToEmail;
                        sentEmail.BCCEmail = BCCEmail;
                        sentEmail.DateTimeSent = DateTimeSent;
                        sentEmail.ToEmailNames = ToEmailNames;
                        sentEmail.CCEmailNames = CCEmailNames;
                        sentEmail.BCCEmailNames = BCCEmailNames;


                        db.SentEmails.Add(sentEmail);
                        db.SaveChanges();
                        return sentEmail.ID;
                    }
                }
                else
                {
                    using (var db = new HuddleSmtpEntities())
                    {
                        InboxEmail inbox = new InboxEmail();
                        inbox.Sender = Sender;
                        inbox.FromEmail = FromEmail;
                        inbox.DateTimeImported = DateTime.Now;
                        inbox.UserPrincipalID = UserID;
                        inbox.UserEmail = Email;
                        inbox.Subject = Subject;
                        inbox.CCEmail = CCEmail;
                        inbox.ToEmail = ToEmail;
                        inbox.BCCEmail = BCCEmail;
                        inbox.DateTimeSent = DateTimeSent;
                        inbox.ToEmailNames = ToEmailNames;
                        inbox.CCEmailNames = CCEmailNames;
                        inbox.BCCEmailNames = BCCEmailNames;


                        db.InboxEmails.Add(inbox);
                        db.SaveChanges();
                        return inbox.ID;
                    }
                }
            }
            catch (Exception e)
            {
                string huh = e.Message;
                return -1;
            }
            
        }


        public static void SaveErrorMessage(string UserName, string Message1, string Message2)
        {
            using (var db = new HuddleSmtpEntities())
            {
                ExceptionLog user = new ExceptionLog();
                user.UserName = UserName;
                user.ErrorMessage1 = Message1;
                user.ErrorMessage2 = Message2;
                user.DateTimeLogged = DateTime.Now;
                db.ExceptionLogs.Add(user);
                db.SaveChanges();
                return;
            }

        }

    }
}
