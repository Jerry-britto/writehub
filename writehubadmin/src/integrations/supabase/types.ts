export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      certificates: {
        Row: {
          certificate_name: string | null
          certificate_url: string | null
          created_at: string
          id: number
          user_id: number | null
        }
        Insert: {
          certificate_name?: string | null
          certificate_url?: string | null
          created_at?: string
          id?: number
          user_id?: number | null
        }
        Update: {
          certificate_name?: string | null
          certificate_url?: string | null
          created_at?: string
          id?: number
          user_id?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "certificates_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      disability: {
        Row: {
          disability_id: number
          disability_name: string
        }
        Insert: {
          disability_id?: number
          disability_name: string
        }
        Update: {
          disability_id?: number
          disability_name?: string
        }
        Relationships: []
      }
      exam_requests: {
        Row: {
          created_at: string
          exam_date: string | null
          exam_time: string | null
          request_id: number
          scribe_id: number | null
          status: string | null
          student_id: number | null
          subject_name: string | null
        }
        Insert: {
          created_at?: string
          exam_date?: string | null
          exam_time?: string | null
          request_id?: number
          scribe_id?: number | null
          status?: string | null
          student_id?: number | null
          subject_name?: string | null
        }
        Update: {
          created_at?: string
          exam_date?: string | null
          exam_time?: string | null
          request_id?: number
          scribe_id?: number | null
          status?: string | null
          student_id?: number | null
          subject_name?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "exam_requests_scribe_id_fkey1"
            columns: ["scribe_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
          {
            foreignKeyName: "exam_requests_student_id_fkey1"
            columns: ["student_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      notification: {
        Row: {
          created_at: string
          message: string | null
          notification_id: number
          title: string | null
          user_id: number | null
        }
        Insert: {
          created_at?: string
          message?: string | null
          notification_id?: number
          title?: string | null
          user_id?: number | null
        }
        Update: {
          created_at?: string
          message?: string | null
          notification_id?: number
          title?: string | null
          user_id?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "notification_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      pending_requests: {
        Row: {
          request_id: number
          user_id: number
        }
        Insert: {
          request_id: number
          user_id: number
        }
        Update: {
          request_id?: number
          user_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "pending_requests_request_id_fkey"
            columns: ["request_id"]
            isOneToOne: false
            referencedRelation: "exam_requests"
            referencedColumns: ["request_id"]
          },
          {
            foreignKeyName: "pending_requests_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      rewards: {
        Row: {
          created_at: string
          reward_id: number
          reward_name: string | null
          scribe_id: number | null
        }
        Insert: {
          created_at?: string
          reward_id?: number
          reward_name?: string | null
          scribe_id?: number | null
        }
        Update: {
          created_at?: string
          reward_id?: number
          reward_name?: string | null
          scribe_id?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "rewards_scribe_id_fkey"
            columns: ["scribe_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      scribes_points: {
        Row: {
          created_at: string
          points: number | null
          record_id: number
          user_id: number | null
        }
        Insert: {
          created_at?: string
          points?: number | null
          record_id?: number
          user_id?: number | null
        }
        Update: {
          created_at?: string
          points?: number | null
          record_id?: number
          user_id?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "scribes_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      user_disabilities: {
        Row: {
          disability_id: number
          user_id: number
        }
        Insert: {
          disability_id: number
          user_id: number
        }
        Update: {
          disability_id?: number
          user_id?: number
        }
        Relationships: [
          {
            foreignKeyName: "user_disabilities_disability_id_fkey"
            columns: ["disability_id"]
            isOneToOne: false
            referencedRelation: "disability"
            referencedColumns: ["disability_id"]
          },
          {
            foreignKeyName: "user_disabilities_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["user_id"]
          },
        ]
      }
      users: {
        Row: {
          academic_year: string | null
          college_proof: string | null
          collegeName: string | null
          course: string | null
          created_at: string
          email: string | null
          fcm_token: string | null
          name: string | null
          phone_number: string | null
          profile_photo: string | null
          role: string | null
          user_id: number
        }
        Insert: {
          academic_year?: string | null
          college_proof?: string | null
          collegeName?: string | null
          course?: string | null
          created_at?: string
          email?: string | null
          fcm_token?: string | null
          name?: string | null
          phone_number?: string | null
          profile_photo?: string | null
          role?: string | null
          user_id?: number
        }
        Update: {
          academic_year?: string | null
          college_proof?: string | null
          collegeName?: string | null
          course?: string | null
          created_at?: string
          email?: string | null
          fcm_token?: string | null
          name?: string | null
          phone_number?: string | null
          profile_photo?: string | null
          role?: string | null
          user_id?: number
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      accept_request: {
        Args: {
          accepted_scribe_id: number
          req_id: number
        }
        Returns: undefined
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type PublicSchema = Database[Extract<keyof Database, "public">]

export type Tables<
  PublicTableNameOrOptions extends
    | keyof (PublicSchema["Tables"] & PublicSchema["Views"])
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
        Database[PublicTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
      Database[PublicTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : PublicTableNameOrOptions extends keyof (PublicSchema["Tables"] &
        PublicSchema["Views"])
    ? (PublicSchema["Tables"] &
        PublicSchema["Views"])[PublicTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  PublicEnumNameOrOptions extends
    | keyof PublicSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends PublicEnumNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = PublicEnumNameOrOptions extends { schema: keyof Database }
  ? Database[PublicEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : PublicEnumNameOrOptions extends keyof PublicSchema["Enums"]
    ? PublicSchema["Enums"][PublicEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof PublicSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof PublicSchema["CompositeTypes"]
    ? PublicSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never
