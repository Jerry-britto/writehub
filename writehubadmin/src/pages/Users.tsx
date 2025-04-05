import React, { useState, useEffect } from "react";
import DashboardLayout from "@/components/dashboard/DashboardLayout";
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Search, UserPlus, Loader2, FileText, Download, Eye, ExternalLink } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import CertificatesList from "@/components/user/CertificatesList";

const Users = () => {
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [roleFilter, setRoleFilter] = useState("all");
  const [isLoading, setIsLoading] = useState(true);
  const [selectedUser, setSelectedUser] = useState(null);
  const [userPoints, setUserPoints] = useState(null);
  const [isProfileModalOpen, setIsProfileModalOpen] = useState(false);
  const [certificates, setCertificates] = useState([]);
  const [selectedDocument, setSelectedDocument] = useState(null);
  const [isDocumentSheetOpen, setIsDocumentSheetOpen] = useState(false);
  const [activeTab, setActiveTab] = useState("list");

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setIsLoading(true);
      const { data, error } = await supabase
        .from("users")
        .select("*");

      if (error) {
        console.error("Error fetching users:", error);
        return;
      }

      setUsers(data || []);
      setFilteredUsers(data || []);
    } catch (error) {
      console.error("Error fetching users:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const fetchUserPoints = async (userId) => {
    try {
      const { data, error } = await supabase
        .from("scribes_points")
        .select("*")
        .eq("user_id", userId)
        .single();

      if (error && error.code !== "PGRST116") {
        console.error("Error fetching user points:", error);
        return null;
      }

      return data;
    } catch (error) {
      console.error("Error fetching user points:", error);
      return null;
    }
  };

  const fetchUserCertificates = async (userId) => {
    try {
      const { data, error } = await supabase
        .from("certificates")
        .select("*")
        .eq("user_id", userId);

      if (error) {
        console.error("Error fetching certificates:", error);
        return [];
      }

      return data || [];
    } catch (error) {
      console.error("Error fetching certificates:", error);
      return [];
    }
  };

  useEffect(() => {
    let result = users;
    
    if (searchQuery) {
      result = result.filter(user => 
        user.name?.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }
    
    if (roleFilter !== "all") {
      result = result.filter(user => user.role === roleFilter);
    }
    
    setFilteredUsers(result);
  }, [searchQuery, roleFilter, users]);

  const handleSearch = (e) => {
    setSearchQuery(e.target.value);
  };

  const handleRoleFilterChange = (value) => {
    setRoleFilter(value);
  };

  const viewUserProfile = async (user) => {
    setSelectedUser(user);
    
    if (user.role === "scribe") {
      const points = await fetchUserPoints(user.user_id);
      setUserPoints(points);
    } else {
      setUserPoints(null);
    }
    
    setIsProfileModalOpen(true);
  };

  const viewUserDocuments = async (user) => {
    window.location.href = `/user-documents?userId=${user.user_id}&name=${encodeURIComponent(user.name || 'User')}`;
  };

  const viewDocument = (document) => {
    setSelectedDocument(document);
    setIsDocumentSheetOpen(true);
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

  const getInitials = (name) => {
    if (!name) return "UN";
    return name
      .split(" ")
      .map(part => part[0])
      .join("")
      .toUpperCase()
      .slice(0, 2);
  };

  return (
    <DashboardLayout>
      <div className="p-4 md:p-8">
        <div className="flex flex-col md:flex-row md:justify-between md:items-center mb-4 md:mb-6 gap-4">
          <h1 className="text-2xl md:text-3xl font-bold">Users</h1>
        </div>

        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="mb-4">
            <TabsTrigger value="list">User List</TabsTrigger>
            <TabsTrigger value="documents">Documents</TabsTrigger>
          </TabsList>

          <TabsContent value="list">
            <Card className="overflow-hidden">
              <CardHeader>
                <CardTitle>User Management</CardTitle>
                <CardDescription>View and manage system users</CardDescription>
                <div className="flex flex-col sm:flex-row gap-4 mt-4">
                  <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={18} />
                    <Input 
                      className="pl-10" 
                      placeholder="Search users by name..." 
                      value={searchQuery}
                      onChange={handleSearch}
                    />
                  </div>
                  <div className="min-w-[180px]">
                    <Select value={roleFilter} onValueChange={handleRoleFilterChange}>
                      <SelectTrigger>
                        <SelectValue placeholder="Filter by role" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Roles</SelectItem>
                        <SelectItem value="swd">Students</SelectItem>
                        <SelectItem value="scribe">Scribes</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </CardHeader>
              <CardContent className="p-0 md:p-6">
                {isLoading ? (
                  <div className="flex justify-center items-center p-8">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                    <span className="ml-2">Loading users...</span>
                  </div>
                ) : filteredUsers.length > 0 ? (
                  <div className="overflow-x-auto">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>ID</TableHead>
                          <TableHead>User</TableHead>
                          <TableHead className="hidden md:table-cell">Email</TableHead>
                          <TableHead className="hidden sm:table-cell">Role</TableHead>
                          <TableHead className="hidden sm:table-cell">College</TableHead>
                          <TableHead className="hidden lg:table-cell">Joined</TableHead>
                          <TableHead>Actions</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {filteredUsers.map((user) => (
                          <TableRow key={user.user_id}>
                            <TableCell className="font-mono text-sm">{user.user_id}</TableCell>
                            <TableCell>
                              <div className="flex items-center space-x-3">
                                <Avatar className="hidden sm:inline-flex">
                                  <AvatarFallback>{getInitials(user.name)}</AvatarFallback>
                                  <AvatarImage src={user.profile_photo || `https://api.dicebear.com/7.x/initials/svg?seed=${user.name}`} />
                                </Avatar>
                                <span className="font-medium">{user.name || 'Unnamed User'}</span>
                              </div>
                            </TableCell>
                            <TableCell className="hidden md:table-cell">{user.email || 'No email'}</TableCell>
                            <TableCell className="hidden sm:table-cell">
                              <span className={`px-2 py-1 rounded-full text-xs ${
                                user.role === "Admin" ? "bg-purple-100 text-purple-800" : 
                                user.role === "Teacher" ? "bg-blue-100 text-blue-800" : 
                                user.role === "Student" ? "bg-green-100 text-green-800" :
                                user.role === "scribe" ? "bg-amber-100 text-amber-800" :
                                "bg-gray-100 text-gray-800"
                              }`}>
                                {user.role || 'No role'}
                              </span>
                            </TableCell>
                            <TableCell className="hidden sm:table-cell">
                              {user.collegeName || 'Not specified'}
                            </TableCell>
                            <TableCell className="hidden lg:table-cell">
                              {new Date(user.created_at).toLocaleDateString()}
                            </TableCell>
                            <TableCell>
                              <div className="flex flex-col sm:flex-row gap-2">
                                {/* <Button variant="outline" size="sm">Edit</Button> */}
                                <Button 
                                  variant="outline" 
                                  size="sm"
                                  onClick={() => viewUserProfile(user)}
                                >
                                  View
                                </Button>
                              </div>
                            </TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </div>
                ) : (
                  <div className="flex justify-center items-center p-8 text-center">
                    <div>
                      <p className="text-lg font-medium mb-2">No users found</p>
                      <p className="text-muted-foreground">
                        {searchQuery || roleFilter !== "all" 
                          ? "Try adjusting your search or filter criteria"
                          : "There are no users in the system yet"}
                      </p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="documents">
            <Card>
              <CardHeader>
                <CardTitle>User Documents</CardTitle>
                <CardDescription>View ID cards and certificates for students and scribes</CardDescription>
                <div className="flex flex-col sm:flex-row gap-4 mt-4">
                  <div className="relative flex-1">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={18} />
                    <Input 
                      className="pl-10" 
                      placeholder="Search users by name..." 
                      value={searchQuery}
                      onChange={handleSearch}
                    />
                  </div>
                  <div className="min-w-[180px]">
                    <Select value={roleFilter} onValueChange={handleRoleFilterChange}>
                      <SelectTrigger>
                        <SelectValue placeholder="Filter by role" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Roles</SelectItem>
                        <SelectItem value="swd">Students</SelectItem>
                        <SelectItem value="scribe">Scribes</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                {isLoading ? (
                  <div className="flex justify-center items-center p-8">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                    <span className="ml-2">Loading users...</span>
                  </div>
                ) : filteredUsers.length > 0 ? (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {filteredUsers.map((user) => (
                      <Card key={user.user_id} className="overflow-hidden">
                        <CardHeader className="p-4">
                          <div className="flex items-center space-x-3">
                            <Avatar>
                              <AvatarFallback>{getInitials(user.name)}</AvatarFallback>
                              <AvatarImage src={user.profile_photo || `https://api.dicebear.com/7.x/initials/svg?seed=${user.name}`} />
                            </Avatar>
                            <div>
                              <CardTitle className="text-base">{user.name || 'Unnamed User'}</CardTitle>
                              <CardDescription>
                                <span className={`px-2 py-0.5 rounded-full text-xs ${
                                  user.role === "Admin" ? "bg-purple-100 text-purple-800" : 
                                  user.role === "Teacher" ? "bg-blue-100 text-blue-800" : 
                                  user.role === "swd" ? "bg-green-100 text-green-800" :
                                  user.role === "scribe" ? "bg-amber-100 text-amber-800" :
                                  "bg-gray-100 text-gray-800"
                                }`}>
                                  {user.role || 'No role'}
                                </span>
                              </CardDescription>
                            </div>
                          </div>
                        </CardHeader>
                        <CardContent className="p-4 pt-0">
                          <div className="space-y-2">
                            {user.college_proof && (
                              <div className="flex justify-between items-center p-2 border rounded">
                                <div className="flex items-center space-x-2">
                                  <FileText className="h-4 w-4 text-blue-600" />
                                  <span className="text-sm">ID Card</span>
                                </div>
                                <div className="flex space-x-1">
                                  <Button 
                                    variant="ghost" 
                                    size="sm" 
                                    onClick={() => viewDocument({ 
                                      url: user.college_proof,
                                      title: "ID Card", 
                                      owner: user.name
                                    })}
                                  >
                                    <Eye className="h-4 w-4" />
                                  </Button>
                                  <Button 
                                    variant="ghost" 
                                    size="sm" 
                                    asChild
                                  >
                                    <a href={user.college_proof} target="_blank" rel="noopener noreferrer">
                                      <ExternalLink className="h-4 w-4" />
                                    </a>
                                  </Button>
                                </div>
                              </div>
                            )}
                          </div>
                        </CardContent>
                        <CardFooter className="p-4 pt-0 flex justify-end">
                          <Button 
                            variant="outline" 
                            size="sm" 
                            onClick={() => viewUserDocuments(user)}
                          >
                            View All Documents
                          </Button>
                        </CardFooter>
                      </Card>
                    ))}
                  </div>
                ) : (
                  <div className="flex justify-center items-center p-8 text-center">
                    <div>
                      <p className="text-lg font-medium mb-2">No users found</p>
                      <p className="text-muted-foreground">
                        {searchQuery || roleFilter !== "all" 
                          ? "Try adjusting your search or filter criteria"
                          : "There are no users in the system yet"}
                      </p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>
      </div>

      <Dialog open={isProfileModalOpen} onOpenChange={setIsProfileModalOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>User Profile</DialogTitle>
            <DialogDescription>
              {selectedUser?.role === "scribe" ? "Scribe details" : "User details"}
            </DialogDescription>
          </DialogHeader>

          {selectedUser && (
            <div className="space-y-4">
              <div className="flex items-center space-x-4">
                <Avatar className="h-16 w-16">
                  <AvatarFallback>{getInitials(selectedUser.name)}</AvatarFallback>
                  <AvatarImage src={selectedUser.profile_photo || `https://api.dicebear.com/7.x/initials/svg?seed=${selectedUser.name}`} />
                </Avatar>
                <div>
                  <h3 className="text-lg font-semibold">{selectedUser.name}</h3>
                  <p className="text-sm text-muted-foreground">
                    <span className={`px-2 py-0.5 rounded-full text-xs ${
                      selectedUser.role === "Admin" ? "bg-purple-100 text-purple-800" : 
                      selectedUser.role === "Teacher" ? "bg-blue-100 text-blue-800" : 
                      selectedUser.role === "swd" ? "bg-green-100 text-green-800" :
                      selectedUser.role === "scribe" ? "bg-amber-100 text-amber-800" :
                      "bg-gray-100 text-gray-800"
                    }`}>
                      {selectedUser.role || 'No role'}
                    </span>
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-sm font-medium text-muted-foreground">ID</p>
                  <p className="font-mono">{selectedUser.user_id}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Email</p>
                  <p>{selectedUser.email || "Not provided"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Phone</p>
                  <p>{selectedUser.phone_number || "Not provided"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">College</p>
                  <p>{selectedUser.collegeName || "Not provided"}</p>
                </div>
                
                {selectedUser.role === "scribe" && userPoints && (
                  <div className="col-span-2">
                    <p className="text-sm font-medium text-muted-foreground">Points Earned</p>
                    <p className="text-xl font-semibold text-green-600">{userPoints.points || 0}</p>
                  </div>
                )}
                
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Course</p>
                  <p>{selectedUser.course || "Not provided"}</p>
                </div>
                <div>
                  <p className="text-sm font-medium text-muted-foreground">Academic Year</p>
                  <p>{selectedUser.academic_year || "Not provided"}</p>
                </div>
                <div className="col-span-2">
                  <p className="text-sm font-medium text-muted-foreground">Joined</p>
                  <p>{new Date(selectedUser.created_at).toLocaleString()}</p>
                </div>
              </div>

              <div className="pt-4 flex justify-end">
                <Button 
                  variant="outline" 
                  onClick={() => viewUserDocuments(selectedUser)}
                >
                  <FileText className="h-4 w-4 mr-2" />
                  View Documents
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>

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

export default Users;
