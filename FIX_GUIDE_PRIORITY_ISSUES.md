# 🔧 Priority Issues Fix Guide

**Status**: Ready to Fix  
**Estimated Total Time**: 5-6 hours  
**Complexity**: Low to Medium

---

## Issue #1: Hard-coded Customer ID ⚠️ CRITICAL

### Current Problem
```dart
// ❌ CURRENT (WRONG)
final inspectionRequest = CreateInspectionRequest(
  customerId: 1, // TODO: Replace with actual customer ID from context
  vehicleTypeId: null,
  vehicleMake: _selectedVehicleMake,
  // ...
);
```

**File**: `frontend/yaman_hybrid_flutter_app/lib/features/inspections/presentation/pages/create_inspection_page.dart`  
**Lines**: 451-478

### Root Cause
The inspection creation form doesn't ask for customer selection. The customer must be provided through the UI.

### Solution

#### Option A: Add Customer Selection Dropdown (RECOMMENDED)

**Step 1**: Add customer provider and state
```dart
// At top of file with other imports
import '../../../../core/providers/customer_provider.dart'; // Add this provider

// In _CreateInspectionPageState class
int? _selectedCustomerId;
```

**Step 2**: Add customer selection UI
```dart
// After "معلومات العميل" section header (around line 107)
_buildSectionHeader('معلومات العميل'),
const SizedBox(height: 16),

// ADD THIS DROPDOWN:
Consumer(
  builder: (context, ref, child) {
    final customers = ref.watch(customersProvider);
    
    return customers.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('خطأ في تحميل العملاء: $error'),
      data: (customersList) => CustomDropdown<int>(
        labelText: 'العميل *',
        hintText: 'اختر العميل',
        value: _selectedCustomerId,
        items: customersList,
        itemLabel: (customer) => customer.name,
        itemValue: (customer) => customer.id,
        onChanged: (customerId) {
          setState(() => _selectedCustomerId = customerId);
        },
        validator: (value) {
          if (value == null) {
            return 'يجب اختيار عميل';
          }
          return null;
        },
      ),
    );
  },
),
const SizedBox(height: 12),
```

**Step 3**: Update the inspection request
```dart
// Replace line 452 with:
customerId: _selectedCustomerId ?? 1, // Use selected customer or default
```

**Step 4**: Add validation
```dart
void _saveInspection() async {
  if (_selectedCustomerId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('يجب اختيار عميل')),
    );
    return;
  }
  
  if (_formKey.currentState?.validate() ?? false) {
    // ... rest of save logic
  }
}
```

---

#### Option B: Get Customer from Route Parameters

If customer is pre-selected before opening this page:

```dart
// In _CreateInspectionPageState
late int _customerId;

@override
void initState() {
  super.initState();
  // Get from route arguments
  _customerId = ModalRoute.of(context)?.settings.arguments as int? ?? 1;
}
```

**Recommended**: Option A (provides better UX)

---

### Testing the Fix

**Test Case 1**: Customer Selection
- [ ] Open Create Inspection page
- [ ] Verify customer dropdown loads
- [ ] Select a customer
- [ ] Fill other fields
- [ ] Save and verify inspection has correct customer ID

**Test Case 2**: Validation
- [ ] Open Create Inspection page
- [ ] Try to save without selecting customer
- [ ] Verify error message shows: "يجب اختيار عميل"

---

## Issue #2: Incomplete Chat Service

### Current Problem
Chat service has no endpoints - just boilerplate.

**File**: `backend/services/chat/main.py`

### Required Endpoints

#### 1. Send Message
```python
@app.post("/api/v1/messages")
async def send_message(message: SendMessageSchema):
    """
    Send a chat message
    
    Args:
        message: Message data with sender_id, receiver_id, content
        
    Returns:
        Created message with ID and timestamp
    """
    try:
        # Validate message
        if not message.content.strip():
            raise ValueError("Message cannot be empty")
        
        # Save to database
        db_message = Message(
            sender_id=message.sender_id,
            receiver_id=message.receiver_id,
            content=message.content,
            created_at=datetime.utcnow(),
            is_read=False
        )
        db.add(db_message)
        db.commit()
        
        return {
            "id": db_message.id,
            "sender_id": db_message.sender_id,
            "receiver_id": db_message.receiver_id,
            "content": db_message.content,
            "timestamp": db_message.created_at.isoformat(),
            "status": "sent"
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/v1/conversations/{conversation_id}/messages")
async def get_messages(conversation_id: int, limit: int = 50):
    """
    Get messages for a conversation
    
    Args:
        conversation_id: ID of the conversation
        limit: Maximum number of messages to return
        
    Returns:
        List of messages
    """
    try:
        messages = db.query(Message).filter(
            Message.conversation_id == conversation_id
        ).order_by(Message.created_at.desc()).limit(limit).all()
        
        return [
            {
                "id": msg.id,
                "sender_id": msg.sender_id,
                "content": msg.content,
                "timestamp": msg.created_at.isoformat(),
                "is_read": msg.is_read
            }
            for msg in reversed(messages)
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/conversations")
async def get_conversations(user_id: int):
    """
    Get all conversations for a user
    
    Args:
        user_id: ID of the user
        
    Returns:
        List of conversations with last message
    """
    try:
        conversations = db.query(Conversation).filter(
            (Conversation.user1_id == user_id) | (Conversation.user2_id == user_id)
        ).all()
        
        return [
            {
                "id": conv.id,
                "participants": [conv.user1_id, conv.user2_id],
                "last_message": conv.last_message,
                "last_update": conv.updated_at.isoformat()
            }
            for conv in conversations
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

#### 2. Mark as Read
```python
@app.put("/api/v1/messages/{message_id}/read")
async def mark_as_read(message_id: int):
    """Mark a message as read"""
    try:
        message = db.query(Message).filter(Message.id == message_id).first()
        if not message:
            raise HTTPException(status_code=404, detail="Message not found")
        
        message.is_read = True
        db.commit()
        
        return {"status": "read", "id": message_id}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

---

## Issue #3: Incomplete AI Chatbot Service

### Current Problem
AI Chatbot service has no endpoints.

**File**: `backend/services/ai_chatbot/main.py`

### Required Endpoints

```python
from fastapi import FastAPI, HTTPException
from datetime import datetime
from typing import Optional

@app.post("/api/v1/chat")
async def chat_with_ai(query: ChatQuerySchema):
    """
    Send message to AI and get response
    
    Args:
        query: User query with optional context
        
    Returns:
        AI response with reasoning
    """
    try:
        # Validate query
        if not query.message.strip():
            raise ValueError("Query cannot be empty")
        
        # Build context
        context = {
            "user_id": query.user_id,
            "conversation_id": query.conversation_id,
            "history": query.history or [],
            "user_context": query.context or {}
        }
        
        # Call AI service (replace with actual AI integration)
        # This could be OpenAI, LLaMA, or custom AI
        response = await call_ai_service(query.message, context)
        
        # Save to database
        chat_record = ChatHistory(
            user_id=query.user_id,
            conversation_id=query.conversation_id,
            user_message=query.message,
            ai_response=response,
            timestamp=datetime.utcnow()
        )
        db.add(chat_record)
        db.commit()
        
        return {
            "response": response,
            "timestamp": datetime.utcnow().isoformat(),
            "id": chat_record.id
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/api/v1/chat/history")
async def get_chat_history(user_id: int, conversation_id: Optional[int] = None):
    """Get AI chat history for user"""
    try:
        query = db.query(ChatHistory).filter(ChatHistory.user_id == user_id)
        
        if conversation_id:
            query = query.filter(ChatHistory.conversation_id == conversation_id)
        
        history = query.order_by(ChatHistory.timestamp.desc()).limit(100).all()
        
        return [
            {
                "id": item.id,
                "user_message": item.user_message,
                "ai_response": item.ai_response,
                "timestamp": item.timestamp.isoformat()
            }
            for item in reversed(history)
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/chat/context")
async def set_context(context: ContextSchema):
    """Set context for AI responses"""
    try:
        # Store context in session/cache
        context_key = f"context:{context.user_id}:{context.conversation_id}"
        
        # Store in cache (Redis recommended)
        cache.set(context_key, context.dict(), ttl=3600)  # 1 hour TTL
        
        return {"status": "context_set"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

---

## Implementation Checklist

### Phase 1: Customer ID Fix (15-20 min)
- [ ] Add `_selectedCustomerId` state variable
- [ ] Add customer dropdown UI
- [ ] Update validation
- [ ] Test locally
- [ ] Push to repository

### Phase 2: Chat Service (2-3 hours)
- [ ] Create database models (Message, Conversation)
- [ ] Implement message endpoints
- [ ] Add validation
- [ ] Write unit tests
- [ ] Deploy to staging
- [ ] Test integration with frontend
- [ ] Deploy to production

### Phase 3: AI Chatbot Service (2-3 hours)
- [ ] Create database models (ChatHistory)
- [ ] Implement chat endpoints
- [ ] Choose AI backend (OpenAI/LLaMA/custom)
- [ ] Write unit tests
- [ ] Deploy to staging
- [ ] Test integration with frontend
- [ ] Deploy to production

---

## Testing Commands

### Frontend Testing
```bash
# Run Flutter tests
flutter test

# Test specific page
flutter test test/features/inspections/create_inspection_page_test.dart
```

### Backend Testing
```bash
# Test chat service
pytest backend/services/chat/tests -v

# Test AI chatbot service
pytest backend/services/ai_chatbot/tests -v

# Test with curl
curl -X POST http://localhost:8000/api/v1/messages \
  -H "Content-Type: application/json" \
  -d '{"sender_id":1,"receiver_id":2,"content":"Hello"}'
```

---

## Rollback Plan

If issues occur:

1. **Frontend**: Switch back to hard-coded customer ID
2. **Backend**: Keep services disabled until fixes are complete
3. **Database**: Maintain migration rollback scripts

---

**Next Step**: Choose an issue to fix first  
**Recommended Order**: Issue #1 → Issue #2 → Issue #3