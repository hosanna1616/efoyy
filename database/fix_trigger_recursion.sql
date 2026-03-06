-- Fix the recursive trigger issue
-- Run this in Supabase SQL Editor to replace the existing trigger

-- Drop the old trigger
DROP TRIGGER IF EXISTS update_queue_positions_trigger ON queue_entries;

-- Create improved function that prevents recursion
CREATE OR REPLACE FUNCTION update_queue_positions()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update if the position actually needs to change
    -- This prevents infinite recursion
    UPDATE queue_entries qe
    SET 
        current_position = sub.row_num - 1,
        total_in_queue = sub.total_count
    FROM (
        SELECT 
            id,
            ROW_NUMBER() OVER (PARTITION BY room ORDER BY queue_number) as row_num,
            COUNT(*) OVER (PARTITION BY room) as total_count
        FROM queue_entries
        WHERE room = COALESCE(NEW.room, OLD.room) AND is_active = true
    ) sub
    WHERE qe.id = sub.id
      AND (
          qe.current_position IS DISTINCT FROM (sub.row_num - 1) OR
          qe.total_in_queue IS DISTINCT FROM sub.total_count
      );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Recreate trigger with better conditions
CREATE TRIGGER update_queue_positions_trigger
    AFTER INSERT OR UPDATE OF queue_number, is_active, room OR DELETE ON queue_entries
    FOR EACH ROW 
    WHEN (
        -- Only trigger if relevant fields changed
        (TG_OP = 'INSERT') OR
        (TG_OP = 'UPDATE' AND (
            OLD.queue_number IS DISTINCT FROM NEW.queue_number OR
            OLD.is_active IS DISTINCT FROM NEW.is_active OR
            OLD.room IS DISTINCT FROM NEW.room
        )) OR
        (TG_OP = 'DELETE')
    )
    EXECUTE FUNCTION update_queue_positions();

