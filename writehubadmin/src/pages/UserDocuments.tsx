
import React, { useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import DashboardLayout from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { ArrowLeft, FileText, Download, Eye, ExternalLink, Loader2 } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";

const UserDocuments = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const params = new URLSearchParams(location.search);
  const userId = params.get("userId");
  const userName = params.get("name") || "User";

  const [certificates, setCertificates] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [user, setUser] = useState(null);
  const [selectedDocument, setSelectedDocument] = useState(null);
  const [isDocumentSheetOpen, setIsDocumentSheetOpen] = useState(false);

  useEffect(() => {
    if (userId) {
      fetchUserData();
      fetchCertificates();
    } else {
      navigate("/users");
    }
  }, [userId]);

  const fetchUserData = async () => {
    try {
      const { data, error } = await supabase
        .from("users")
        .select("*")
        .eq("user_id", userId)
        .single();

      if (error) {
        console.error("Error fetching user:", error);
        return;
      }

      setUser(data);
    } catch (error) {
      console.error("Error:", error);
    }
  };

  const fetchCertificates = async () => {
    try {
      setIsLoading(true);
      const { data, error } = await supabase
        .from("certificates")
        .select("*")
        .eq("user_id", userId);

      if (error) {
        console.error("Error fetching certificates:", error);
        return;
      }

      setCertificates(data || []);
    } catch (error) {
      console.error("Error:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const getFileExtension = (url) => {
    if (!url) return '';
    return url.split('.').pop().toLowerCase();
  };

  const isImageFile = (url) => {
    const ext = getFileExtension(url);
    return ['jpg', 'jpeg', 'png', 'gif', 'svg', 'webp'].includes(ext);
  };

  const isPdfFile = (url) => {
    return getFileExtension(url) === 'pdf';
  };

  const viewDocument = (document) => {
    setSelectedDocument(document);
    setIsDocumentSheetOpen(true);
  };

  return (
    <DashboardLayout>
      <div className="p-8">
        <div className="flex items-center gap-4 mb-6">
          <Button variant="outline" onClick={() => navigate("/users")}>
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back to Users
          </Button>
          <h1 className="text-3xl font-bold">Documents for {userName}</h1>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>User Documents</CardTitle>
            <CardDescription>Certificates and identification documents</CardDescription>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <div className="flex justify-center items-center py-8">
                <Loader2 className="h-8 w-8 animate-spin text-primary" />
                <span className="ml-2">Loading documents...</span>
              </div>
            ) : (
              <div className="space-y-3">
                {user?.college_proof && (
                  <div className="flex justify-between items-center p-3 border rounded">
                    <div className="flex items-center space-x-2">
                      <FileText className="h-4 w-4 text-blue-600" />
                      <div>
                        <span className="font-medium">College ID Card</span>
                        <p className="text-xs text-muted-foreground">
                          {getFileExtension(user.college_proof).toUpperCase()} File
                        </p>
                      </div>
                    </div>
                    <div className="flex space-x-2">
                      <Button 
                        variant="outline" 
                        size="sm" 
                        onClick={() => viewDocument({ 
                          url: user.college_proof, 
                          title: "College ID Card", 
                          owner: user.name || "User"
                        })}
                      >
                        <Eye className="h-4 w-4 mr-2" />
                        View
                      </Button>
                      <Button 
                        variant="outline" 
                        size="sm" 
                        asChild
                      >
                        <a href={user.college_proof} download>
                          <Download className="h-4 w-4" />
                        </a>
                      </Button>
                    </div>
                  </div>
                )}

                {certificates.length > 0 ? (
                  certificates.map((cert) => (
                    <div key={cert.id} className="flex justify-between items-center p-3 border rounded">
                      <div className="flex items-center space-x-2">
                        <FileText className="h-4 w-4 text-green-600" />
                        <div>
                          <span className="font-medium">{cert.certificate_name || `Certificate #${cert.id}`}</span>
                          <p className="text-xs text-muted-foreground">
                            {getFileExtension(cert.certificate_url).toUpperCase()} File
                            {cert.created_at && ` • Added ${new Date(cert.created_at).toLocaleDateString()}`}
                          </p>
                        </div>
                      </div>
                      <div className="flex space-x-2">
                        <Button 
                          variant="outline" 
                          size="sm" 
                          onClick={() => viewDocument({ 
                            url: cert.certificate_url, 
                            title: cert.certificate_name || `Certificate #${cert.id}`, 
                            owner: user?.name || "User"
                          })}
                        >
                          <Eye className="h-4 w-4 mr-2" />
                          View
                        </Button>
                        <Button 
                          variant="outline" 
                          size="sm" 
                          asChild
                        >
                          <a href={cert.certificate_url} target="_blank" rel="noopener noreferrer">
                            <ExternalLink className="h-4 w-4" />
                          </a>
                        </Button>
                      </div>
                    </div>
                  ))
                ) : (
                  <div className="text-center py-6 text-muted-foreground">
                    {user?.role === "swd" ? "No certificates found for this student" : "No additional documents found"}
                  </div>
                )}
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      <Sheet open={isDocumentSheetOpen} onOpenChange={setIsDocumentSheetOpen}>
        <SheetContent className="sm:max-w-lg w-full" side="right">
          <SheetHeader>
            <SheetTitle>{selectedDocument?.title}</SheetTitle>
            <SheetDescription>
              Document for {selectedDocument?.owner}
            </SheetDescription>
          </SheetHeader>
          
          <div className="mt-6 space-y-4">
            {selectedDocument && (
              <>
                <div className="flex justify-between items-center">
                  <span className="text-sm text-muted-foreground">{getFileExtension(selectedDocument.url).toUpperCase()} File</span>
                  <Button 
                    variant="outline" 
                    size="sm" 
                    asChild
                  >
                    <a href={selectedDocument.url} download>
                      <Download className="h-4 w-4 mr-2" />
                      Download
                    </a>
                  </Button>
                </div>
                
                <div className="border rounded-md overflow-hidden">
                  {isImageFile(selectedDocument.url) ? (
                    <img 
                      src={selectedDocument.url} 
                      alt={selectedDocument.title} 
                      className="w-full h-auto"
                    />
                  ) : isPdfFile(selectedDocument.url) ? (
                    <iframe 
                      src={`${selectedDocument.url}#toolbar=0`} 
                      title={selectedDocument.title}
                      className="w-full h-[70vh]"
                    />
                  ) : (
                    <div className="p-8 text-center">
                      <FileText className="h-12 w-12 mx-auto text-muted-foreground" />
                      <p className="mt-2 text-muted-foreground">
                        This file type cannot be previewed
                      </p>
                      <Button 
                        className="mt-4" 
                        asChild
                      >
                        <a href={selectedDocument.url} target="_blank" rel="noopener noreferrer">
                          <ExternalLink className="h-4 w-4 mr-2" />
                          Open in New Tab
                        </a>
                      </Button>
                    </div>
                  )}
                </div>
              </>
            )}
          </div>
        </SheetContent>
      </Sheet>
    </DashboardLayout>
  );
};

export default UserDocuments;
