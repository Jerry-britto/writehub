import React, { useState, useEffect } from "react";
import DashboardLayout from "@/components/dashboard/DashboardLayout";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { CalendarIcon, PlusCircle, Filter } from "lucide-react";
import { supabase } from "@/integrations/supabase/client";
import { useToast } from "@/components/ui/use-toast";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { format } from "date-fns";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Input } from "@/components/ui/input";
import sendNotification from "@/lib/notiification_util";

const ExamBooking = () => {
  const [exams, setExams] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [users, setUsers] = useState<any[]>([]);
  const [selectedExamId, setSelectedExamId] = useState<number | null>(null);
  const [scribeIdInput, setScribeIdInput] = useState<string>("");
  const [isAssigningScribe, setIsAssigningScribe] = useState(false);
  const { toast } = useToast();

  // Fetch users to get names for student_id and scribe_id
  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const { data, error } = await supabase
          .from("users")
          .select("user_id, name");

        if (error) throw error;

        setUsers(data || []);
      } catch (error) {
        console.error("Error fetching users:", error);
      }
    };

    fetchUsers();
  }, []);

  // Fetch exams from Supabase
  useEffect(() => {
    const fetchExams = async () => {
      try {
        setLoading(true);
        let query = supabase.from("exam_requests").select("*");

        // Apply filter if not "all"
        if (statusFilter !== "all") {
          query = query.eq("status", statusFilter);
        }

        const { data, error } = await query;

        if (error) {
          throw error;
        }

        setExams(data || []);
      } catch (error) {
        console.error("Error fetching exams:", error);
        toast({
          title: "Error fetching exams",
          description: "Could not load exam data. Please try again.",
          variant: "destructive",
        });
      } finally {
        setLoading(false);
      }
    };

    fetchExams();
  }, [statusFilter, toast]);

  // Format date for display
  const formatDate = (dateString: string) => {
    if (!dateString) return "N/A";
    try {
      return format(new Date(dateString), "yyyy-MM-dd");
    } catch (e) {
      return dateString;
    }
  };

  // Format time for display
  const formatTime = (timeString: string) => {
    if (!timeString) return "N/A";
    return timeString;
  };

  // Get user name by ID
  const getUserName = (userId: number) => {
    if (!userId) return "N/A";
    const user = users.find((u) => u.user_id === userId);
    return user ? user.name : "Unknown";
  };

  const rewardUser = async (scribeId: number) => {
    try {
      // get scribe's points
      const { data: user, error: userError } = await supabase
        .from("scribes_points")
        .select("points")
        .eq("user_id", scribeId)
        .single();

      if (userError) throw Error("Could not retrieve user points");

      const totalPoints = user.points;

      // find reward category
      let rewardCategory = null;
      if (totalPoints >= 10 && totalPoints < 20) rewardCategory = "Bronze";
      else if (totalPoints >= 20 && totalPoints < 30) rewardCategory = "Silver";
      else if (totalPoints >= 30 && totalPoints < 40) rewardCategory = "Gold";
      else if (totalPoints >= 40 && totalPoints < 50)
        rewardCategory = "Platinum";
      else if (totalPoints >= 50) rewardCategory = "Diamond";

      if (!rewardCategory || rewardCategory === null) {
        console.log("user not elgible to take reward")
        return;
      };

      console.log("reward to be given ",rewardCategory);

      // check whether the reward is already awared or not to the scribe
      const exisingReward = await supabase
        .from("rewards")
        .select("reward_name")
        .eq("scribe_id", scribeId)
        .eq("reward_name", rewardCategory)
        .maybeSingle();

      if (exisingReward.error) throw Error("rewards could not be retrieved");

      if (exisingReward.data) {
        console.log(
          `User ${scribeId} has already received the ${rewardCategory} reward.`
        );
        return;
      }
      
      // provide the reward to the scribe
      const { error: insertError } = await supabase
        .from("rewards")
        .insert({ scribe_id: scribeId, reward_name: rewardCategory });

      if (insertError) throw insertError;

       // send notification
       await supabase.from("notification").insert({
        user_id: scribeId,
        title: "Reward unlocked",
        message:
          `Congragulations you have been awarded a ${rewardCategory} medal. You can meet your college staff for collecting your respective reward`,
      });

      const result = await supabase
        .from("users")
        .select("fcm_token")
        .eq("user_id", scribeId)
        .single();

      if (result.error) {
        console.error("Error fetching FCM token:", result.error);
      } else if (result.data && result.data.fcm_token) {
        await sendNotification(
          result.data.fcm_token,
          "Reward unlocked",
          `Congragulations you have been awarded a ${rewardCategory} medal. You can meet your college staff for collecting your respective reward`
        );
      } else {
        console.error("No FCM token found for the user.");
      }

    } catch (error) {
      console.log(
        "Error occured while rewarding the user due to ",
        error.toString()
      );
    }
  };

  // Mark exam as completed
  const markExamAsCompleted = async (
    examId: number,
    scribeId: number | null
  ) => {
    try {
      // Update exam status
      const { error: updateError } = await supabase
        .from("exam_requests")
        .update({ status: "COMPLETED" })
        .eq("request_id", examId);

      if (updateError) throw updateError;

      // Add points to scribe if scribe exists
      if (scribeId) {
        console.log("inserting new points");
        // First check if the scribe already has points
        const { data: existingPoints, error: fetchError } = await supabase
          .from("scribes_points")
          .select("*")
          .eq("user_id", scribeId);
        console.log("inserting scribe ", existingPoints);
        if (fetchError) throw fetchError;

        if (existingPoints && existingPoints.length > 0) {
          // Update existing points by adding 3.5
          const currentPoints = existingPoints[0].points || 0;
          const newPoints = currentPoints + 3.5;

          const { error: updatePointsError } = await supabase
            .from("scribes_points")
            .update({ points: newPoints })
            .eq("user_id", scribeId);

          if (updatePointsError) throw updatePointsError;
        } else {
          console.log("updating new points");
          // Insert new points record if none exists
          const { error: pointsError } = await supabase
            .from("scribes_points")
            .insert({
              user_id: scribeId,
              points: 3.5,
            });

          if (pointsError) throw pointsError;
        }
      }

      // send notification
      await supabase.from("notification").insert({
        user_id: scribeId,
        title: "Points credited",
        message: "Congrats you got 3.5 points",
      });

      const result = await supabase
        .from("users")
        .select("fcm_token")
        .eq("user_id", scribeId)
        .single();

      if (result.error) {
        console.error("Error fetching FCM token:", result.error);
      } else if (result.data && result.data.fcm_token) {
        await sendNotification(
          result.data.fcm_token,
          "Points credited",
          "Congrats! You got 3.5 points."
        );
      } else {
        console.error("No FCM token found for the user.");
      }

      await rewardUser(scribeId)

      // Refresh exams
      const { data, error } = await supabase.from("exam_requests").select("*");
      if (error) throw error;

      setExams(data || []);

      toast({
        title: "Exam marked as completed",
        description: scribeId
          ? "3.5 points have been awarded to the scribe."
          : "No scribe was assigned to this exam.",
      });
    } catch (error) {
      console.error("Error marking exam as completed:", error);
      toast({
        title: "Error",
        description: "Could not mark exam as completed. Please try again.",
        variant: "destructive",
      });
    }
  };

  // Assign scribe to exam
  const assignScribeToExam = async (examId: number, scribeId: string) => {
    try {
      const scribeIdNumber = parseInt(scribeId);

      if (isNaN(scribeIdNumber)) {
        toast({
          title: "Invalid ID",
          description: "Please enter a valid scribe ID.",
          variant: "destructive",
        });
        return;
      }

      // if the status is pending or backup needed remove all the requests from pending reqeusts table
      await supabase.from("pending_requests").delete().eq("request_id", examId);

      // Check if scribe exists
      const { data: scribeData, error: scribeError } = await supabase
        .from("users")
        .select("user_id, role")
        .eq("user_id", scribeIdNumber)
        .single();

      if (scribeError || !scribeData) {
        toast({
          title: "Scribe not found",
          description: "Could not find a user with that ID.",
          variant: "destructive",
        });
        return;
      }

      if (scribeData.role !== "scribe") {
        toast({
          title: "Invalid role",
          description: "The user ID provided is not a scribe.",
          variant: "destructive",
        });
        return;
      }

      // Update exam with scribe ID
      const { error: updateError } = await supabase
        .from("exam_requests")
        .update({
          scribe_id: scribeIdNumber,
          status: "FULFILLED",
        })
        .eq("request_id", examId);

      if (updateError) throw updateError;

      // Refresh exams
      const { data, error } = await supabase.from("exam_requests").select("*");
      if (error) throw error;

      setExams(data || []);
      setScribeIdInput("");
      setIsAssigningScribe(false);

      // send notification
      await supabase.from("notification").insert({
        user_id: scribeIdNumber,
        title: "Admin's message",
        message:
          "Hi you have being assigned for an exam. Please check the app for more details",
      });

      const result = await supabase
        .from("users")
        .select("fcm_token")
        .eq("user_id", scribeIdNumber)
        .single();

      if (result.error) {
        console.error("Error fetching FCM token:", result.error);
      } else if (result.data && result.data.fcm_token) {
        await sendNotification(
          result.data.fcm_token,
          "Admin's message",
          "Hi you have being assigned for an exam. Please check the app for more details"
        );
      } else {
        console.error("No FCM token found for the user.");
      }

      toast({
        title: "Scribe assigned",
        description: "The scribe has been successfully assigned to this exam.",
      });
    } catch (error) {
      console.error("Error assigning scribe:", error);
      toast({
        title: "Error",
        description: "Could not assign scribe to exam. Please try again.",
        variant: "destructive",
      });
    }
  };

  return (
    <DashboardLayout>
      <div className="p-4 md:p-8">
        <Card className="overflow-hidden">
          <CardHeader className="flex flex-col md:flex-row md:items-center md:justify-between">
            <div>
              <CardTitle>Exam Requests</CardTitle>
              <CardDescription>
                View and manage examination requests
              </CardDescription>
            </div>
            <div className="flex items-center mt-4 md:mt-0">
              <Filter className="mr-2 h-4 w-4 text-muted-foreground" />
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Filter by status" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Statuses</SelectItem>
                  <SelectItem value="PENDING">Pending</SelectItem>
                  <SelectItem value="FULFILLED">Fulfilled</SelectItem>
                  <SelectItem value="COMPLETED">Completed</SelectItem>
                  <SelectItem value="BACKUP NEEDED">Cancelled</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardHeader>
          <CardContent className="p-0 md:p-6">
            <div className="overflow-x-auto">
              {loading ? (
                <div className="flex justify-center items-center py-8">
                  <p>Loading exam requests...</p>
                </div>
              ) : exams.length === 0 ? (
                <div className="flex justify-center items-center py-8">
                  <p>No exam requests found.</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Subject</TableHead>
                      <TableHead className="hidden sm:table-cell">
                        Date
                      </TableHead>
                      <TableHead className="hidden md:table-cell">
                        Time
                      </TableHead>
                      <TableHead>Student</TableHead>
                      <TableHead>Scribe</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {exams.map((exam) => (
                      <TableRow key={exam.request_id}>
                        <TableCell className="font-medium">
                          {exam.subject_name || "Untitled"}
                        </TableCell>
                        <TableCell className="hidden sm:table-cell">
                          {formatDate(exam.exam_date)}
                        </TableCell>
                        <TableCell className="hidden md:table-cell">
                          {formatTime(exam.exam_time)}
                        </TableCell>
                        <TableCell>{getUserName(exam.student_id)}</TableCell>
                        <TableCell>
                          {exam.scribe_id ? (
                            getUserName(exam.scribe_id)
                          ) : (
                            <span className="text-gray-500 italic">
                              No scribe assigned
                            </span>
                          )}
                        </TableCell>
                        <TableCell>
                          <div
                            className={`inline-flex px-2 py-1 rounded-full text-xs font-medium ${
                              exam.status === "FULFILLED"
                                ? "bg-green-100 text-green-800"
                                : exam.status === "COMPLETED"
                                ? "bg-blue-100 text-blue-800"
                                : exam.status === "PENDING"
                                ? "bg-yellow-100 text-yellow-800"
                                : "bg-red-100 text-red-800"
                            }`}
                          >
                            {exam.status || "Unknown"}
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex flex-col sm:flex-row gap-2">
                            {/* Mark as Complete Button */}
                            <AlertDialog>
                              <AlertDialogTrigger asChild>
                                <Button
                                  variant="outline"
                                  size="sm"
                                  disabled={
                                    exam.status === "COMPLETED" ||
                                    exam.status == "PENDING" ||
                                    exam.status === "BACKUP NEEDED"
                                  }
                                >
                                  Mark Complete
                                </Button>
                              </AlertDialogTrigger>
                              <AlertDialogContent>
                                <AlertDialogHeader>
                                  <AlertDialogTitle>
                                    Are you sure?
                                  </AlertDialogTitle>
                                  <AlertDialogDescription>
                                    This will mark the exam as completed. If a
                                    scribe is assigned, they will receive 3.5
                                    points.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Cancel</AlertDialogCancel>
                                  <AlertDialogAction
                                    onClick={() =>
                                      markExamAsCompleted(
                                        exam.request_id,
                                        exam.scribe_id
                                      )
                                    }
                                  >
                                    Confirm
                                  </AlertDialogAction>
                                </AlertDialogFooter>
                              </AlertDialogContent>
                            </AlertDialog>

                            {/* Assign Scribe Button */}
                            <AlertDialog
                              open={
                                isAssigningScribe &&
                                selectedExamId === exam.request_id
                              }
                              onOpenChange={(open) => {
                                if (!open) {
                                  setIsAssigningScribe(false);
                                  setSelectedExamId(null);
                                  setScribeIdInput("");
                                }
                              }}
                            >
                              <AlertDialogTrigger asChild>
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => {
                                    setSelectedExamId(exam.request_id);
                                    setIsAssigningScribe(true);
                                  }}
                                  disabled={exam.status === "COMPLETED"}
                                >
                                  Assign Scribe
                                </Button>
                              </AlertDialogTrigger>
                              <AlertDialogContent>
                                <AlertDialogHeader>
                                  <AlertDialogTitle>
                                    Assign a Scribe
                                  </AlertDialogTitle>
                                  <AlertDialogDescription>
                                    Enter the ID of the scribe you want to
                                    assign to this exam.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <div className="mb-4">
                                  <Input
                                    type="number"
                                    placeholder="Enter Scribe ID"
                                    value={scribeIdInput}
                                    onChange={(e) =>
                                      setScribeIdInput(e.target.value)
                                    }
                                  />
                                </div>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Cancel</AlertDialogCancel>
                                  <AlertDialogAction
                                    onClick={() =>
                                      assignScribeToExam(
                                        exam.request_id,
                                        scribeIdInput
                                      )
                                    }
                                    disabled={!scribeIdInput}
                                  >
                                    Assign
                                  </AlertDialogAction>
                                </AlertDialogFooter>
                              </AlertDialogContent>
                            </AlertDialog>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default ExamBooking;
