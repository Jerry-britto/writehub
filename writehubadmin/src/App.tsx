import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { SidebarProvider } from "@/components/ui/sidebar";
import Dashboard from "./pages/Index";
import ExamBooking from "./pages/ExamBooking";
import Users from "./pages/Users";
import UserDocuments from "./pages/UserDocuments";
import Rewards from "./pages/Rewards";
import NotFound from "./pages/NotFound";
import LoginPage from "./pages/LoginPage";
import ProtectedRoute from "./components/ProtectedRoute";
import RedirectIfAuthenticated from "./components/RedirectIfAuthenticated";

const queryClient = new QueryClient();

const App = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <SidebarProvider>
          <TooltipProvider>
            <Toaster />
            <Sonner />
            <Routes>
              <Route element={<RedirectIfAuthenticated />}>
                <Route path="/login" element={<LoginPage />} />
              </Route>
              <Route element={<ProtectedRoute />}>
                <Route path="/" element={<ExamBooking />} />
                <Route path="/exam-booking" element={<ExamBooking />} />
                <Route path="/users" element={<Users />} />
                <Route path="/user-documents" element={<UserDocuments />} />
                <Route path="/rewards" element={<Rewards />} />
              </Route>
              <Route path="*" element={<NotFound />} />
            </Routes>
          </TooltipProvider>
        </SidebarProvider>
      </BrowserRouter>
    </QueryClientProvider>
  );
};

export default App;
