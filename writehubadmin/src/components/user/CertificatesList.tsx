
import React, { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { FileText, Download, Eye, ExternalLink, Loader2 } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";

interface Certificate {
  id: number;
  certificate_name: string;
  certificate_url: string;
  created_at: string;
}

interface CertificatesListProps {
  userId: number;
  onViewDocument: (document: { url: string; title: string; owner: string }) => void;
}

const CertificatesList: React.FC<CertificatesListProps> = ({ userId, onViewDocument }) => {
  const [certificates, setCertificates] = useState<Certificate[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    fetchCertificates();
    fetchUser();
  }, [userId]);

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

  const fetchUser = async () => {
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

  const getFileExtension = (url: string) => {
    if (!url) return '';
    return url.split('.').pop()?.toLowerCase() || '';
  };

  return (
    <Card className="mt-4">
      <CardHeader>
        <CardTitle className="text-lg">Certificates & Documents</CardTitle>
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
                    onClick={() => onViewDocument({ 
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
                      onClick={() => onViewDocument({ 
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
  );
};

export default CertificatesList;
