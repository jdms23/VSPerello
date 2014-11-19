SET OLEOBJECT ON

FaxServer=createobject('FAXCOMEX.FaxServer')
FaxDoc = CreateObject("FAXCOMEX.FaxDocument")
FaxServer.Connect('') &&name of the fax server or blank for local PC

&&Check if the service is busy...
IF FaxServer.activity.OutgoingMessages>0
MESSAGEBOX("Fax service is busy. Please try Later",48,"Busy")
RETURN .F.
ENDIF

FaxDoc.body="c:\docs\po12345.pdf" &&The document itself
FaxDoc.DocumentName = "automated fax"
FaxDoc.Recipients.add(1)
FaxDoc.Recipients.item(1).name="First Guy"
FaxDoc.Recipients.item(1).FaxNumber="080012345"
FaxDoc.Recipients.add(2)
FaxDoc.Recipients.item(2).name="Second Guy"
FaxDoc.Recipients.item(2).FaxNumber="080054321"

FaxDoc.coverpagetype=1 &&1 is local
FaxDoc.CoverPage="FullPath ... \confdent.cov" &&enter the full path to the COV file
FaxDoc.Sender.Email = ""
FaxDoc.Sender.Name = "My NAme"
FaxDoc.subject="Automated Fax Purchase Order"
FaxDoc.Sender.FaxNumber = "+44(0)1234xxxyyy"
FaxDoc.ReceiptType = 0
FaxDoc.ReceiptAddress = ""
FaxDoc.AttachFaxToReceipt = .F.

JobID = FaxDoc.ConnectedSubmit(FaxServer)

DO CASE
CASE TYPE("JobID")!="C"
MESSAGEBOX("FAX NOT SUBMITTED FOR SENDING!",48,"Fax Failure")
llRetVal=.F.
CASE ALEN(JobID,1)=FaxDoc.Recipients.count
MESSAGEBOX(ALLTRIM(STR(ALEN(JobID,1)))+" Job"+IIF(ALEN(JobID,1)>1,"s","")+" submitted for sending",48,"Fax submitted for sending")
llRetVal=.T.
CASE ALEN(JobID,1)!=FaxDoc.Recipients.count
MESSAGEBOX("Failed to submit the correct number of fax jobs to the server"+CHR(13)+"Some recipients may not receive your fax",48,"Incorrect number of jobs submitted")
llRetVal=.F.
OTHERWISE
MESSAGEBOX("Unknown error"+CHR(13)+"Some recipients may not receive your fax",48,"Unknown Error")
llRetVal=.F.
ENDCASE


RETURN llRetVal